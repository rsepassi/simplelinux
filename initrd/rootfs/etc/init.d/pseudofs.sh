#!/bin/sh
# Mount various pseudo-filesystems provided by the kernel

mkdir -p /proc /sys /dev /tmp
mount -t proc     proc /proc
mount -t sysfs    sysfs    /sys
mount -t devtmpfs devtmpfs /dev
mount -t tmpfs    tmpfs    /tmp

mkdir -p /dev/shm /dev/pts /sys/fs/cgroup /dev/hugepages /dev/mqueue
mount -t tmpfs     tmpfs     /dev/shm
mount -t devpts    devpts    /dev/pts
mount -t cgroup2   cgroup2   /sys/fs/cgroup
mount -t hugetlbfs hugetlbfs /dev/hugepages
mount -t mqueue    mqeue     /dev/mqueue

ln -s /dev/rtc0 /dev/rtc
ln -s /proc/self/fd /dev/fd
ln -s /proc/self/fd/0 /dev/stdin
ln -s /proc/self/fd/1 /dev/stdout
ln -s /proc/self/fd/2 /dev/stderr
