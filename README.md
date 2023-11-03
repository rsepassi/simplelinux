# simplelinux

A Linux OS simple enough to build and edit yourself.

Build for `{x86, x86_64, arm, arm64, riscv64}`.

## Quick start

Build in a Podman container and then launch with QEMU:

```
$ ARCH=x86_64 \
  SSH_KEY="$(cat ~/.ssh/*.pub)" \
  ./scripts/simplelinux.sh

simplelinux build

start: Thu Nov  2 04:58:19 PM PDT 2023
log: /home/simp/simplelinux/build/out/x86_64/build_log.txt
end:   Thu Nov  2 05:03:12 PM PDT 2023
outputs: /home/simp/simplelinux/build/out/x86_64

1.3M build_log.txt
1.2M busybox
807K dropbearmulti
1.1M initramfs.cpio.gz
1.1M initramfs.tar.gz
13M kernel
64M simplelinux.img

simplelinux build complete

$ ARCH=x86_64 \
  PORT=8181 \
  ./scripts/qemu.sh



      ====== simplelinux ======



booted in 1.64 seconds

Please press Enter to activate this console.
```

You can SSH in on port 8181: `ssh root@localhost -p 8181`.

## Code Tour

`scripts/simplelinux.sh` sets up a minimal Alpine Linux container and runs
`scripts/build.sh` within in, which in turn runs the following:

```
./scripts/getdeps.sh  # apk build dependencies
./scripts/getsrcs.sh  # download sources
./busybox/build.sh    # build busybox
./ssh/build.sh        # build dropbear
./kernel/build.sh     # build linux
./initrd/build.sh     # build root filesystem
./boot/build.sh       # build boot image
```

## Options

`simplelinux` is configured through a few environment variables. Further
configuration should be done by editing the files.

Build:

```
# one of {x86, x86_64, arm, arm64, riscv64}
ARCH=x86_64

# one of the names in kernel/configs/$ARCH, or default
KERNEL_CONFIG=default

# public key(s) to put into /root/.ssh/authorized_keys
SSH_KEY="$(cat ~/.ssh/*.pub)"

# if 1, mounts pwd and drops into shell
DEBUG=0

./scripts/simplelinux.sh
```

Boot:

```
# one of {x86, x86_64, arm, arm64, riscv64}
ARCH=x86_64

# one of {kernel, boot}
# kernel uses QEMU's ability to a directly boot a Linux kernel
# boot uses simplelinux.img with either BIOS or UEFI
MODE=kernel

# port forward for ssh
PORT=8181

# optionally attach a disk, typically created by qemu-img
# if not partitioned, use fdisk, and then mkfs.ext2 to create a fs
# example mount: mount /dev/vda /home
DATA_DISK=/path/to/data.img

./scripts/qemu.sh
```

Run initramfs in a Podman container:

```
# one of {x86, x86_64, arm, arm64, riscv64}
ARCH=x86_64

./scripts/podman.sh
```

## System admin

`simplelinux` uses `runit` for its init system.

* `/etc/runit/1`: One-time startup tasks
* `/etc/runit/2`: Long-running services
* `/etc/runit/3`: Shutdown tasks

`simplelinux uses `runsv` for service management.

Services can be started/stopped by adding/removing a directory to
`/var/service`. Use `sv` to query and manage services (`sv status
/var/service/*` to see the status for all services).

Default startup tasks:
* Install busybox symlinks
* Set hostname
* Mount pseudo-filesystems
* Startup banner

Default services:
* syslog
* cron
* dhcp
* ntp
* ssh

Default shutdown tasks:
* Stop services
* Turn off swap
* Unmount filesystems

## Kernel configuration

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

`minconfig` boots in QEMU with KVM in <0.3s, the kernel and initramfs weigh in
at <4MiB, and the system uses ~12MiB of memory after startup.

## TODO
* Non-root user
* wget HTTPS
