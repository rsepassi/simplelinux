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
* `simplelinux.iso`

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
./initrd/init.sh   # the /init program
./boot/limine.cfg  # bootloader config

# Extract initramfs and run it in Podman
./scripts/podman.sh

# Run the built kernel and initramfs in QEMU
./scripts/qemu.sh

# Run build.sh in a container
./airlock/build.sh    # build Dockerfile and run ./build.sh
./airlock/Dockerfile  # Alpine-based build image
```

Total lines: 595

```
# find . -type f | \
         grep -v "\/\.git\/" | \
         grep -v "\/sources\/" | \
         grep -v "README" | \
         grep -v "LICENSE" | \
         grep -v "\.gitignore" | \
    xargs wc -l | sort -nr

  595 total
  112 ./boot/build.sh
  103 ./busybox/build.sh
   93 ./env.sh
   57 ./scripts/qemu.sh
   43 ./kernel/build.sh
   32 ./initrd/build.sh
   30 ./scripts/download.sh
   27 ./build.sh
   26 ./airlock/build.sh
   25 ./airlock/Dockerfile
   21 ./scripts/podman.sh
   13 ./initrd/init.sh
   13 ./boot/limine.cfg
```

## Future directions

* Test that this all works from an `arm64` host (currently only has been tested
  from a `x86_64` host)
* Make the bootable image work across architectures (BIOS+UEFI)
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
