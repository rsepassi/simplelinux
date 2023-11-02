#!/bin/sh
# Build simplelinux

set -e

. ./scripts/config.sh

mkdir -p $BUILD_DIR

# apk build dependencies
./scripts/getdeps.sh

# sources
./scripts/getsrcs.sh

# busybox
./busybox/build.sh

# dropbear
./ssh/build.sh

# linux
./linux/build.sh

# ramfs
./initrd/build.sh

# bootloader
./boot/build.sh

echo "========================================"
echo "Build complete. Output artifacts:"
ls -lh $BUILD_DIR
echo "Run ./scripts/qemu.sh to launch in QEMU"
