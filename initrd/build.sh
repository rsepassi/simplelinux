#!/bin/sh
set -e

TITLE="Building initrd archives"
echo $TITLE

SRC=$SLROOT
DST=$SRC/sources/rootfs

# Start fresh
rm -rf $DST
mkdir -p $DST
cd $DST

# Setup directories
mkdir -p usr/bin sys tmp bin root proc

# Copy in init
cp -r $SRC/initrd/init.sh $DST/init

# Copy in busybox
cp $SRC/sources/busybox/busybox bin/

# Setup /bin/sh
ln -s /bin/busybox bin/sh

# Package
find . | cpio --quiet -o -H newc | gzip -9 > $INITRD_PATH
tar -czf $INITRD_TAR_PATH .
ls -lh $INITRD_PATH $INITRD_TAR_PATH

echo "DONE: $TITLE"
