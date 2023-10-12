#!/bin/sh
set -e

. ./env.sh

rm -rf sources/build
mkdir -p sources/build

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
echo "Build complete. Output artifacts:"
ls -lh sources/build
echo "Run ./scripts/qemu.sh to launch in QEMU"
