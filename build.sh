#!/bin/sh
set -e

. ./config.sh

mkdir -p $BUILD_DIR
rm -rf $BUILD_DIR/*

# sources
./scripts/download.sh

# busybox
./busybox/build.sh

# linux
./kernel/build.sh

# dropbear
./ssh/build.sh

# ramfs
./initrd/build.sh

# bootloader
./boot/build.sh

echo "========================================"
echo "Build complete. Output artifacts:"
ls -lh $BUILD_DIR
echo "Run ./scripts/qemu.sh to launch in QEMU"
