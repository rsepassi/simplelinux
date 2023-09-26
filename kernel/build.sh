#!/bin/sh
set -e

export PATH=$PATH:$PWD/clang-cross
cd sources/linux/linux-6.5

# https://docs.kernel.org/kbuild/llvm.html
clangmake() {
  make \
    LLVM=1 \
    ARCH=arm64 \
    CC=clang-16 \
    LD=ld.lld-16 \
    AR=clang-cross-ar \
    NM=llvm-nm-16 \
    STRIP=llvm-strip-16 \
    OBJCOPY=llvm-objcopy-16 \
    OBJDUMP=llvm-objdump-16 \
    READELF=llvm-readelf-16 \
    HOSTCC=clang-cross-hostcc \
    HOSTCXX=clang-c++-16 \
    HOSTAR=clang-cross-ar \
    HOSTLD=ld.lld-16 \
    $1
}

clangmake defconfig
clangmake -j128
