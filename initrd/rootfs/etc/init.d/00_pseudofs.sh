#!/bin/sh

set -e

mkdir -p /proc
mount -t proc proc /proc

mkdir -p /sys
mount -t sysfs sysfs /sys

mkdir -p /dev
mount -t devtmpfs devtmpfs /dev

mkdir -p /dev/shm
mount -t tmpfs tmpfs /dev/shm

mkdir -p /dev/pts
mount -t devpts devpts /dev/pts

ln -s /dev/rtc0 /dev/rtc
ln -s /proc/self/fd /dev/fd
ln -s /proc/self/fd/0 /dev/stdin
ln -s /proc/self/fd/1 /dev/stdout
ln -s /proc/self/fd/2 /dev/stderr
