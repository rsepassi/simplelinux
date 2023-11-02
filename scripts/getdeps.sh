#!/bin/sh
# Install Alpine build dependencies

set -e

apk update

# Compiler toolchain
apk add -q make llvm16 clang16 musl-dev lld

# Additional Linux build dependencies
apk add -q linux-headers flex bison elfutils-dev openssl-dev perl rsync ncurses-dev

# For boot image creation
apk add -q nasm mtools parted

# For easier cross-compilation of busybox+dropbear
apk add -q zig \
      --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing
