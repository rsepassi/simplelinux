#!/bin/sh
# Build the root filesystem archives
set -e

TITLE="Building initramfs archives"
echo $TITLE

SRC=$SLROOT
DST=$SRC/build/rootfs

# Start fresh
rm -rf $DST
cp -r $SLROOT/ramfs/rootfs $DST
cd $DST

# Create some directories
mkdir -p \
  proc sys usr dev tmp sbin home root \
  usr/sbin \
  etc/dropbear etc/udhcp \
  var/service \
  home/user/.ssh

# Copy in busybox
cp $BUSYBOX_PATH bin/

# Copy in dropbear
cp $DROPBEAR_PATH usr/bin/

# Networking
cp $SRC/build/busybox/examples/udhcp/simple.script etc/udhcp/

# SSH
echo "$SSH_KEY" > home/user/.ssh/authorized_keys

# Package
find . | cpio --quiet -o -H newc | gzip -9 > $INITRD_PATH
tar -czf $INITRD_TAR_PATH .
ls -lh $INITRD_PATH $INITRD_TAR_PATH

echo "DONE: $TITLE"
