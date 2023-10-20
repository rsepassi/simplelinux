#!/bin/sh
set -e

TITLE="Building initrd archives"
echo $TITLE

SRC=$SLROOT
DST=$SRC/sources/rootfs

# Start fresh
rm -rf $DST
cp -r $SLROOT/initrd/rootfs $DST
cd $DST

# Copy in busybox
cp $BUSYBOX_PATH bin/

# Copy in dropbear
cp $DROPBEAR_PATH usr/bin/

# Copy in Zig
# cp -r $BUILD_DIR/zig root/
# ln -s /root/zig/zig usr/bin/zig

# Networking
mkdir -p etc/udhcp
cp $SRC/sources/busybox/examples/udhcp/simple.script etc/udhcp/

# SSH
mkdir -p root/.ssh
echo "$SSH_KEY" > root/.ssh/authorized_keys

# Package
find . | cpio --quiet -o -H newc | gzip -9 > $INITRD_PATH
tar -czf $INITRD_TAR_PATH .
ls -lh $INITRD_PATH $INITRD_TAR_PATH

echo "DONE: $TITLE"
