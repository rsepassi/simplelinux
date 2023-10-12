# Linux build

A simplified "Linux from Scratch".

Cross-compiles using llvm to:
* `x86`
* `x86_64`
* `riscv64`
* `arm`
* `arm64`

```
# on host system
ZIGROOT_ARCH=x86_64 ./build.sh

# or in a podman container
ZIGROOT_ARCH=x86_64 ./airlock/build.sh
```

The build script does the following:
* Downloads sources for busybox, Linux, Limine (`scripts/download.sh`)
* Builds busybox, statically linked (`busybox/build.sh`)
* Builds Linux (`kernel/build.sh`)
* Builds initramfs (`initrd/build.sh`)
* Builds bootable image (`boot/build.sh`)

To run the built kernel in QEMU:

```
./scripts/qemu.sh
```
