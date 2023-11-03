#!/bin/sh
# Download all simplelinux sources

set -e

TITLE="Downloading and extracting sources"
echo $TITLE

SRC=$SLROOT/build
mkdir -p $SRC

CACHE=$HOME/.cache/simplelinux/downloads
mkdir -p $CACHE
cd $CACHE

dl() {
  local_name="$1"
  local_file="$2"
  local_url="$3"
  local_dst="$SRC/$local_name"

  echo $local_name
  test -f "$local_file" || wget "$local_url/$local_file"
  rm -rf $local_dst
  mkdir -p $local_dst
  tar -xf $local_file -C $local_dst --strip-components=1
}

dl limine "limine-$LIMINE_VERSION.tar.gz" "https://github.com/limine-bootloader/limine/releases/download/v$LIMINE_VERSION"
dl busybox "busybox-$BUSYBOX_VERSION.tar.bz2" "https://www.busybox.net/downloads"
dl linux "linux-$LINUX_VERSION.tar.xz" "https://cdn.kernel.org/pub/linux/kernel/v6.x"
dl dropbear "dropbear-$DROPBEAR_VERSION.tar.bz2" "https://matt.ucc.asn.au/dropbear/releases"
dl zlib "zlib-$ZLIB_VERSION.tar.gz" "https://www.zlib.net"

echo "DONE: $TITLE"
