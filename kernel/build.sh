#!/bin/sh
set -e

cd sources/linux/linux-6.5

# https://docs.kernel.org/kbuild/llvm.html
clangmake() {
  make LLVM=-16 ARCH=arm64 $1
}

clangmake defconfig
clangmake -j128
