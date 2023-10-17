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

# Setup some directories
mkdir -p \
  bin \
  root/.ssh \
  var/spool/cron/crontabs \
  usr/bin \
  etc/udhcp \
  etc/ssl/certs \
  etc/init.d \
  etc/dropbear

# Copy in init
ln -s /bin/busybox init
cp -r $SRC/initrd/init.sh etc/init.d/rcS

# Copy in busybox
cp $BUSYBOX_PATH bin/

# Copy in dropbear
cp $SSH_PATH usr/bin/

# Setup /bin/sh
ln -s /bin/busybox bin/sh

# Networking
cp $SRC/sources/busybox/examples/udhcp/simple.script etc/udhcp/
cp /etc/ssl/certs/ca-certificates.crt etc/ssl/certs/
echo simplelinux > etc/hostname
cat << EOF > etc/hosts
127.0.0.1       localhost
127.0.1.1       simplelinux
EOF

# User
echo "root:x:0:0:root:/root:/bin/sh" > etc/passwd
echo "root:*::0:::::" > etc/shadow

# Cron
echo "# min   hour    day     month   weekday command" > var/spool/cron/crontabs/root

# SSH
echo "$SSH_KEY" > root/.ssh/authorized_keys

# Package
find . | cpio --quiet -o -H newc | gzip -9 > $INITRD_PATH
tar -czf $INITRD_TAR_PATH .
ls -lh $INITRD_PATH $INITRD_TAR_PATH

echo "DONE: $TITLE"
