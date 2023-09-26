#!/bin/sh
set -e

SRC=$PWD/sources
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
  rm -r $local_dst
  mkdir -p $local_dst
  tar -xf $local_file -C $local_dst
}

dl busybox "busybox-1.36.0.tar.bz2" "https://www.busybox.net/downloads"
dl linux "v6.5.tar.gz" "https://github.com/torvalds/linux/archive/refs/tags"
dl zig "zig-linux-aarch64-0.11.0.tar.xz" "https://ziglang.org/download/0.11.0"
