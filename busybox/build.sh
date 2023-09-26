#!/bin/sh
set -e

ROOT=$PWD
export PATH=$PATH:$PWD/clang-cross

cd sources/busybox/busybox-1.36.0
make defconfig

CFLAGS="-Wno-string-plus-int -Wno-ignored-optimization-argument -Wno-unused-command-line-argument -Wno-unused-result" \
LDFLAGS="--static" \
CROSS_COMPILE="clang-cross-" \
make -j128 busybox_unstripped

zig objcopy --strip-all busybox_unstripped busybox
chmod +x busybox
