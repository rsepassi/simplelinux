#!/bin/sh
# Mount various pseudo-filesystems provided by the kernel

mount -t proc     proc     /proc
mount -t sysfs    sysfs    /sys
mount -t tmpfs    tmpfs    /tmp

# /dev
mount -t devtmpfs devtmpfs /dev
mkdir /dev/shm /dev/pts /dev/mqueue
mount -t tmpfs     tmpfs     /dev/shm
mount -t devpts    devpts    /dev/pts
mount -t mqueue    mqueue    /dev/mqueue

ln -s /dev/rtc0 /dev/rtc
ln -s /proc/self/fd /dev/fd
ln -s /proc/kcore /dev/core
ln -s /proc/self/fd/0 /dev/stdin
ln -s /proc/self/fd/1 /dev/stdout
ln -s /proc/self/fd/2 /dev/stderr
