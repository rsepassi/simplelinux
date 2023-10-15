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
    ./initrd/build.sh      # build initramfs
    ./boot/build.sh        # build bootable image

# Files copied into initramfs
./initrd/init.sh        # the /init program
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

  623 total
  119 ./boot/build.sh
  103 ./busybox/build.sh
  100 ./env.sh
   60 ./scripts/qemu.sh
   43 ./kernel/build.sh
   32 ./initrd/build.sh
   30 ./scripts/download.sh
   27 ./build.sh
   26 ./airlock/build.sh
   25 ./airlock/Dockerfile
   21 ./scripts/podman.sh
   13 ./initrd/init.sh
   13 ./boot/limine.cfg
   13 ./boot/limine_uefi.cfg
```

## Notes

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
        -> Kernel hacking
          -> printk and dmesg options
            Show timing information on printks
    ```

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

* Add networking
* Add ssh
* Add an init system (runit or OpenRC)
* Add a (encrypted) disk
* Minimal image that can
  * Run a static C/Zig binary
  * Build a static C/Zig binary
  * Run a dynamic C/Zig binary
  * Build a dynamic C/Zig binary
  * Run Podman
  * Build itself
  * Emulate itself
* Investigate Secure Boot and encrypted filesystems
* Run on cloud
* Run on real hardware
  * Server
  * Desktop
  * Phone
