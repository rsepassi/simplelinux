#!/bin/sh

set -e

# mount filesystems in /etc/fstab
mkdir -p /proc /sys /dev
mount -av

# mount these afterwards so that we can create /dev subdirectories
mkdir /dev/shm /dev/pts
mount -t tmpfs tmpfs /dev/shm
mount -t devpts devpts /dev/pts

ln -s /dev/rtc0 /dev/rtc
ln -s /proc/self/fd /dev/fd
ln -s /proc/self/fd/0 /dev/stdin
ln -s /proc/self/fd/1 /dev/stdout
ln -s /proc/self/fd/2 /dev/stderr
