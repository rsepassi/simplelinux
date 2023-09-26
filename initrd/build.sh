#!/bin/sh
set -e

SRC=$PWD
DST=/tmp/rootfs

# Clear
rm -rf $DST

# Initialize
cp -r $SRC/initrd/rootfs $DST
cd $DST

# Make directories
mkdir -p usr/bin sys tmp dev bin home/root proc

# Copy in zig and busybox
cp -r $SRC/sources/zig/zig-linux-aarch64-0.11.0 $DST/home/root/zig
cp $SRC/sources/busybox/busybox-1.36.0/busybox $DST/bin/

# Package
cd $DST
find . | cpio -o -H newc > /tmp/initramfs.cpio
