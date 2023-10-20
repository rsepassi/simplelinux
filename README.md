# simplelinux

A simple Linux distribution that you can read and edit yourself.

Cross-compile in a Podman airlock:

```
ARCH=x86_64 ./airlock/build.sh
```

Supports cross-compiling to `{x86, x86_64, riscv64, arm, arm64}`.

Build outputs will be available in `sources/build/$ARCH`:
* `kernel`: a compiled Linux kernel
* `initramfs.cpio.gz`, `initramfs.tar.gz`: an initramfs in 2 formats
* `simplelinux.img`: a bootable image (BIOS+UEFI or UEFI)
* `busybox`: statically-compiled BusyBox binary
* `dropbearmulti`: statically-compiled Dropbear SSH multi-binary
* `zig`: Zig install directory. Note that this is not included in initramfs.

To run the built kernel and initramfs in QEMU:

```
ARCH=x86_64 ./scripts/qemu.sh
```

To load the initramfs in Podman:

```
ARCH=x86_64 ./scripts/podman.sh
```

## Code Tour

Here are all the sources in the repo.

```
# Run build.sh in a container
./airlock/build.sh    # build Dockerfile and run ./build.sh
./airlock/Dockerfile  # Alpine-based build image

# Build is the entrypoint and calls the indented scripts
./build.sh                 # entrypoint
    ./config.sh            # configuration
    ./scripts/download.sh  # wget sources
    ./busybox/build.sh     # build busybox
    ./ssh/build.sh         # build dropbear
    ./kernel/build.sh      # build Linux
    ./initrd/build.sh      # build initramfs
    ./boot/build.sh        # build bootable image

# Files copied into initramfs
./initrd/rootfs         # basis for initramfs

# Files copied into boot image
./boot/limine.cfg       # bootloader config for BIOS/UEFI systems
./boot/limine_uefi.cfg  # bootloader config for UEFI-only systems

# Scripts
./scripts/podman.sh  # extract initramfs and run it in Podman
./scripts/qemu.sh    # run the built kernel and initramfs in QEMU
```

```
# find . -type f | \
         grep -v "\/\.git\/" | \
         grep -v "\/sources\/" | \
         grep -v "\/configs\/" | \
         grep -v "README" | \
         grep -v "LICENSE" | \
         grep -v "TODO" | \
         grep -v "\.gitignore" | \
    sort | xargs wc -l

   40 ./airlock/build.sh
   25 ./airlock/Dockerfile
   89 ./boot/build.sh
   13 ./boot/limine.cfg
   11 ./boot/limine_uefi.cfg
   30 ./build.sh
   76 ./busybox/build.sh
  110 ./config.sh
   41 ./initrd/build.sh
    2 ./initrd/rootfs/bin/fakelogin
    4 ./initrd/rootfs/etc/fstab
    1 ./initrd/rootfs/etc/hostname
    2 ./initrd/rootfs/etc/hosts
   24 ./initrd/rootfs/etc/init.d/00_pseudofs.sh
   17 ./initrd/rootfs/etc/inittab
    5 ./initrd/rootfs/etc/ntp.conf
    1 ./initrd/rootfs/etc/passwd
   15 ./initrd/rootfs/etc/runit/1
    2 ./initrd/rootfs/etc/runit/2
    8 ./initrd/rootfs/etc/runit/3
    4 ./initrd/rootfs/etc/service/cron/run
    3 ./initrd/rootfs/etc/service/dhcp/run
    3 ./initrd/rootfs/etc/service/ntp/run
    3 ./initrd/rootfs/etc/service/ssh/run
    2 ./initrd/rootfs/etc/service/syslog/run
    1 ./initrd/rootfs/etc/spool/cron/crontabs/root
    1 ./initrd/rootfs/etc/shadow
   52 ./kernel/build.sh
   32 ./scripts/download.sh
   31 ./scripts/podman.sh
   50 ./scripts/qemu.sh
   25 ./ssh/build.sh
  719 total
```

## Notes

### Options

```
ARCH=x86_64           \  # one of {x86, x86_64, arm, arm64, riscv64}
KERNEL_CONFIG=default \  # one of the names in kernel/configs/$ARCH, or default
SSH_KEY="$mykey"      \  # a public key to put into /root/.ssh/authorized_keys
DEBUG=0               \  # if 1, mounts ./ and drops into shell
QEMU=0                \  # if 1, runs built artifacts in QEMU
./airlock/build.sh
```

```
ARCH=x86_64           \  # one of {x86, x86_64, arm, arm64, riscv64}
MODE=kernel           \  # one of {kernel, boot}
./scripts/qemu.sh
```

```
ARCH=x86_64           \  # one of {x86, x86_64, arm, arm64, riscv64}
./scripts/podman.sh
```

### Init

`simplelinux` uses a combination of BusyBox init and BusyBox runit.

BusyBox init is the actual `init` program and is configured by `/etc/inittab`,
which does the following:
* Run `/etc/runit/1` to do all one-time setup tasks
* Run `/etc/runit/2` as a service to start and manage all services
* Run `/bin/sh` on the console
* On shutdown, run `/etc/runit/3`

`/etc/runit/1` does the following:

* Adds BusyBox symlinks
* Quiets kernel logging
* Sets the hostname
* Runs all scripts in `/etc/init.d`
    * Mount pseudo filesystems
* Shows the welcome banner

`/etc/runit/2` links the service definitions in `/etc/service` to `/var/service`
and starts them:
  * syslog: system logging, use `logread` to read and `logger` to log
  * dhcp: setup networking on eth0 and maintain a dhcp lease
  * cron: run cron jobs (per-user crontabs in `/var/spool/cron/crontabs`)
  * ntp: keep time using ntp.org servers (servers listed in `/etc/ntp.conf`)
  * ssh: Dropbear SSH server, creates a server key at
    `/etc/dropbear/dropbear_ed25519_host_key` on first connection, authorized
    keys at `/root/.ssh/authorized_keys`.

Query service status with `sv status`, e.g. `sv status dhcp`, or query all
services with `sv status /var/service/*`.

Manage services with `sv`. You can also stop a service by removing the symlink
in `/var/service` and start one by adding a symlink there.

All logs go to `syslogd` tagged with the service name.

### Kernel configuration

By default, the Linux kernel is configured with its `defconfig` make rule.
To specify an alternative config, you can place a configuration file in
`kernel/configs/$KERNEL_ARCH/some_config_name`.

The available ones in the repo for `x86_64` are:
* `defconfig`: `clangmake defconfig`
* `allnoconfig`: `clangmake allnoconfig` (note: simplelinux init will fail)
* `minconfig` (compressed kernel <3MiB): `minconfig` + the following +
  `clangmake kvm_guest.config`
    ```
        -> General setup
            System V IPC
            Initial RAM filesystem and RAM disk (initramfs/initrd) support
              Only gzip compression
            Configure standard kernel features
              Deselect "Load all symbols for debugging"
        -> Executable file formats
            Kernel support for ELF binaries
            Kernel support for scripts starting with #!
            Disable core dump support
        -> Networking support
          -> Networking options
            Packet socket
            Unix domain sockets
            TCP/IP networking
        -> Device Drivers
          -> Generic driver options
            Maintain a devtmpfs filesystem
          -> Character devices
            -> Serial drivers
              8250/16550 and compatible serial support
              Console on 8250/16550 and compatible serial port
        -> File systems
          -> Pseudo filesystems
            Tmpfs virtual memory file system support
    ```

`clangmake` is the `make` wrapper generated in `kernel/build.sh`.

`minconfig` boots in QEMU in <0.6s, the kernel and initramfs weigh in at <4MiB,
and the system uses ~8MiB of memory after startup.

### Boot image

The bootable image `simplelinux.img` has support for:
* `x86`: BIOS, UEFI
* `x86_64`: BIOS, UEFI
* `arm`: UEFI
  * Limine does not support arm, but because the Linux kernel can act as an
    EFI executable, simplelinux inserts a `startup.nsh` script which will be
    run by the UEFI shell. Note that the UEFI shell is typically the last boot
    method tried by UEFI and so you may have to wait until all the other methods
    are tried and fail ("UEFI Misc Device", "UEFI Misc Device 2", "UEFI PXEv4",
    "UEFI PXEv6", "HTTP Boot over IPv4", "HTTP Boot over IPv6", ...).
* `arm64`: UEFI
* `riscv64`: UEFI

Note that to run the images on QEMU with UEFI, paths to the UEFI firmware must
be passed to QEMU. See `QEMU_BIOS_ARG` in `config.sh`.

All have been tested except for riscv64, for which UEFI firmware is not readily
available (let me know if you can test this; the image is UEFI compatible).

### Self-hosting

Currently, building simplelinux requires Alpine Linux and some of its packages.
It would be nice to be able to build simplelinux from within simplelinux. That
would require packaging the fetched dependencies in the Dockerfile:

```
# compiler toolchain
make
llvm16
clang16
musl-dev
lld
zig

# for linux
flex
bison
elfutils-dev
openssl-dev
perl
rsync
ncurses-dev

# for limine
nasm

# for boot image creation
mtools
parted
```
