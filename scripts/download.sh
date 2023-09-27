#!/bin/sh
set -e

echo "Downloading and extracting sources"

SRC=$ZIGROOT/sources
mkdir -p $SRC

CACHE=$HOME/.cache/zigroot/downloads
mkdir -p $CACHE
cd $CACHE

dl() {
  local_name="$1"
  local_file="$2"
  local_url="$3"
  local_dst="$SRC/$local_name"

  test -f "$local_file" || wget "$local_url/$local_file"
  rm -rf $local_dst
  mkdir -p $local_dst
  tar -xf $local_file -C $local_dst --strip-components=1
}

dl simpleboot "simpleboot-$SIMPLEBOOT_VERSION.tar.gz" "https://gitlab.com/bztsrc/simpleboot/-/archive/$SIMPLEBOOT_VERSION"
dl busybox "busybox-$BUSYBOX_VERSION.tar.bz2" "https://www.busybox.net/downloads"
dl linux "v$LINUX_VERSION.tar.gz" "https://github.com/torvalds/linux/archive/refs/tags"
