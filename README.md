# simplelinux

Compile a Linux kernel and BusyBox, and keep it simple enough to see how it's
done.

```
# Runs build in a container, see airlock/Dockerfile
# Requires podman to build and qemu-system-* to run the resulting kernel
ARCH=x86_64 ./airlock/build.sh
```

Can cross-compile to `{x86, x86_64, riscv64, arm, arm64}`.

Build outputs will be available in `sources/build`:
* `kernel`
* `initramfs.cpio.gz`, `initramfs.tar.gz`
* `busybox`
* `simplelinux.img`
* `dropbear`

To run the built kernel and initramfs in QEMU:

```
./scripts/qemu.sh
```

## Tour

Here are all the sources in the repo.

```
# Build is the entrypoint and calls the indented scripts
./build.sh                 # entrypoint
    ./env.sh               # configuration
    ./scripts/download.sh  # wget sources
    ./busybox/build.sh     # build busybox
    ./kernel/build.sh      # build Linux
    ./ssh/build.sh         # build dropbear
    ./initrd/build.sh      # build initramfs
    ./boot/build.sh        # build bootable image

# Files copied into initramfs
./initrd/init.sh        # run as rcS by busybox init
./boot/limine.cfg       # bootloader config for BIOS/UEFI systems
./boot/limine_uefi.cfg  # bootloader config for UEFI-only systems

# Extract initramfs and run it in Podman
./scripts/podman.sh

# Run the built kernel and initramfs in QEMU
./scripts/qemu.sh

# Run build.sh in a container
./airlock/build.sh    # build Dockerfile and run ./build.sh
./airlock/Dockerfile  # Alpine-based build image
```

```
# find . -type f | \
         grep -v "\/\.git\/" | \
         grep -v "\/sources\/" | \
         grep -v "\/configs\/" | \
         grep -v "README" | \
         grep -v "LICENSE" | \
         grep -v "\.gitignore" | \
    xargs wc -l | sort -nr

  718 total
  110 ./env.sh
   89 ./boot/build.sh
   76 ./busybox/build.sh
   69 ./scripts/qemu.sh
   63 ./initrd/build.sh
   53 ./initrd/init.sh
   52 ./kernel/build.sh
   40 ./airlock/build.sh
   32 ./scripts/download.sh
   31 ./scripts/podman.sh
   30 ./build.sh
   25 ./airlock/Dockerfile
   24 ./ssh/build.sh
   13 ./boot/limine.cfg
   11 ./boot/limine_uefi.cfg
```

## Notes

### Init

`simplelinux` uses BusyBox init (for now). `initrd/init.sh` is the entire
init script. It does the following:
* Add busybox symlinks
* Quiet kernel logging
* Mount pseudo filesystems
* Setup `syslogd` to log to a circular buffer (use `logread -F` to read)
* Setup `ntpd` to keep time using ntp.org servers
* Setup `crond` to run cron jobs
* Setup networking for eth0 with `udhcpc`
* Setup ssh with `dropbear`

That's it.

### Kernel configuration

By default, the Linux kernel is configured with its `defconfig` make rule.
To specify an alternative config, you can place a configuration file in
`kernel/configs/$KERNEL_ARCH/some_config_name`.

The available ones in the repo for `x86_64` are:
* `defconfig`: `clangmake defconfig`
* `allnoconfig`: `clangmake allnoconfig`
* `minconfig` (compressed kernel <2M): allnoconfig + the following:
    ```
        -> General setup
            Initial RAM filesystem and RAM disk (initramfs/initrd) support
              Only gzip compression
            Configure standard kernel features
              Deselect debug symbols
        -> Executable file formats
            Kernel support for ELF binaries
            Kernel support for scripts starting with #!
            Disable core dump support
        -> Device Drivers
          -> Character devices
            8250/16550 and compatible serial support
            Console on 8250/16550 and compatible serial port
    ```
* `minconfig_kvm` (compressed kernel <3M): `minconfig` +
  `clangmake kvm_guest.config`

`clangmake` is the `make` wrapper generated in `kernel/build.sh`.

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
be passed to QEMU. See `QEMU_BIOS_ARG` in `env.sh`.

All have been tested except for riscv64, for which UEFI firmware is not readily
available (let me know if you can test this; the image is UEFI compatible).

## Some todos

* Consider init/supervisor systems (runit or OpenRC)
* Add cron
* Add a (encrypted) disk
* Run on cloud
* Run on real hardware
  * Server
  * Desktop
  * Phone
