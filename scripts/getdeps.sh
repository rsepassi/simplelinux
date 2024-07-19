#!/bin/sh
# Install Alpine build dependencies

set -e

apk update -q

# Compiler toolchain
apk add -q make llvm16 clang16 musl-dev lld
ln -s /usr/bin/clang-16 /usr/bin/clang
ln -s /usr/bin/clang++-16 /usr/bin/clang++
ln -s /usr/bin/llvm16-ar /usr/bin/llvm-ar
ln -s /usr/bin/llvm16-nm /usr/bin/llvm-nm
ln -s /usr/bin/llvm16-objcopy /usr/bin/llvm-objcopy
ln -s /usr/bin/llvm16-objdump /usr/bin/llvm-objdump
ln -s /usr/bin/llvm16-readelf /usr/bin/llvm-readelf
ln -s /usr/bin/llvm16-strip /usr/bin/llvm-strip

# Additional Linux build dependencies
apk add -q \
  linux-headers \
  flex bison \
  elfutils-dev \
  openssl-dev \
  perl \
  rsync \
  ncurses-dev

# For boot image creation
apk add -q nasm mtools parted

# For easier cross-compilation of busybox+dropbear
zig_arch="x86_64"
[ "$(uname -m)" = "arm64" ] && zig_arch="aarch64"
zig_url="https://ziglang.org/download/$ZIG_VERSION/zig-linux-$zig_arch-$ZIG_VERSION.tar.xz"
test -f $SLCACHE/zig.tar.xz || wget -q $zig_url -O $SLCACHE/zig.tar.xz
mkdir $HOME/zig
tar xf $SLCACHE/zig.tar.xz -C $HOME/zig --strip-components=1
ln -s $HOME/zig/zig /usr/bin/zig
