#!/bin/sh
set -e

TITLE="Building busybox"
echo $TITLE

cd sources/busybox
make defconfig HOSTCC="zig-cross-hostcc"

CFLAGS="-Wno-string-plus-int -Wno-ignored-optimization-argument -Wno-unused-command-line-argument -Wno-unused-result" \
LDFLAGS="--static" \
CROSS_COMPILE="zig-cross-" \
make -j64 busybox_unstripped

zig objcopy --strip-all busybox_unstripped busybox
chmod +x busybox

echo "DONE: $TITLE"
