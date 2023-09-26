#!/bin/sh
set -e

ROOT=$PWD
export PATH=$PATH:$PWD/clang-cross

cd sources/busybox/busybox-1.36.0
test -f ".patch" || git apply --directory=sources/busybox/busybox-1.36.0 $ROOT/patches/busybox.patch
touch .patch
make defconfig

CFLAGS="-Wno-string-plus-int -Wno-ignored-optimization-argument -Wno-unused-command-line-argument -Wno-unused-result" \
LDFLAGS="--static" \
CROSS_COMPILE="clang-cross-" \
make busybox_unstripped

zig objcopy --strip-all busybox_unstripped busybox
chmod +x busybox
