#!/bin/sh
set -e

. ./env.sh

# sources
./scripts/download.sh

# busybox
./busybox/build.sh

# kernel
./kernel/build.sh

# ramfs
./initrd/build.sh

# bootloader
./boot/build.sh

echo "========================================"
echo "Build complete"
echo "Kernel: $KERNEL_PATH"
echo "initramfs: $INITRD_PATH"
echo "Bootable disk image: $IMG_PATH"
echo "Run ./scripts/qemu.sh to launch in QEMU"
