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

# Setup some directories
mkdir -p \
  var/service \
  tmp \
  root/.ssh \
  etc/udhcp \
  etc/ssl/certs \
  etc/dropbear

# Copy in busybox
cp $BUSYBOX_PATH bin/

# Copy in dropbear
cp $DROPBEAR_PATH usr/bin/

# Networking
cp $SRC/sources/busybox/examples/udhcp/simple.script etc/udhcp/
cp /etc/ssl/certs/ca-certificates.crt etc/ssl/certs/

# SSH
echo "$SSH_KEY" > root/.ssh/authorized_keys

# Package
find . | cpio --quiet -o -H newc | gzip -9 > $INITRD_PATH
tar -czf $INITRD_TAR_PATH .
ls -lh $INITRD_PATH $INITRD_TAR_PATH

echo "DONE: $TITLE"
