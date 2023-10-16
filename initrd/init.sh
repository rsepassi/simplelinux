#!/bin/sh
set -e
echo "=== simplelinux init ==="
/bin/busybox --install -s /usr/bin
dmesg -n 3
mount -t proc none /proc
mount -t sysfs none /sys
export HOME=/root
echo "Boot took $(awk '{print $1*1000}' /proc/uptime) milliseconds"

echo "=== busybox init ==="
exec /bin/busybox init -s
