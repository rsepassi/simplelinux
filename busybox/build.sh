#!/bin/sh
set -e

export PATH=$PATH:$PWD/clang-cross

cd sources/busybox/busybox-1.36.0
make defconfig
LDFLAGS="--static" CROSS_COMPILE="clang-cross-" make busybox
