#!/bin/sh
set -e

TITLE="Building Linux kernel to $KERNEL_PATH"
echo $TITLE

# https://docs.kernel.org/kbuild/llvm.html
clang_flags="
    LLVM=1 \
    ARCH=$KERNEL_ARCH \
    CC=clang \
    LD=ld.lld \
    AR=llvm-ar \
    NM=llvm-nm \
    STRIP=llvm-strip \
    OBJCOPY=llvm-objcopy \
    OBJDUMP=llvm-objdump \
    READELF=llvm-readelf \
    HOSTCC=clang \
    HOSTCXX=clang-c++ \
    HOSTAR=llvm-ar \
    HOSTLD=ld.lld \
"

cd sources/linux

# Start fresh
make "$clang_flags" clean
echo "Linux cleaned"

# Configure
make $clang_flags defconfig
echo "Linux configured"

# Build
make $clang_flags -j32
echo "Linux built"

cp $KERNEL_SRC_PATH $KERNEL_PATH

echo "DONE: $TITLE"
