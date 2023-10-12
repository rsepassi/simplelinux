#!/bin/sh
set -e

echo "=== simplelinux init ==="
/bin/busybox --install -s /usr/bin
dmesg -n 3
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
export HOME=/root

echo "=== busybox init ==="
exec /bin/busybox init -s
