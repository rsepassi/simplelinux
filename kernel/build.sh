#!/bin/sh
set -e

echo "Building Linux kernel"

# https://docs.kernel.org/kbuild/llvm.html
clangmake() {
  make \
    LLVM=1 \
    ARCH=$KERNEL_ARCH \
    CC=clang-16 \
    LD=ld.lld-16 \
    AR=zig-cross-ar \
    NM=llvm-nm-16 \
    STRIP=llvm-strip-16 \
    OBJCOPY=llvm-objcopy-16 \
    OBJDUMP=llvm-objdump-16 \
    READELF=llvm-readelf-16 \
    HOSTCC=clang-16 \
    HOSTCXX=clang-c++-16 \
    HOSTAR=zig-cross-ar \
    HOSTLD=ld.lld-16 \
    $1
}

cd sources/linux
clangmake defconfig
clangmake -j32
