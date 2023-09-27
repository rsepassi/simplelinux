#!/bin/sh
set -e

echo "Building boot image"

# Build simpleroot
cd $ZIGROOT/sources/simpleboot/src
zig cc -ansi -Wall -Wextra -O2 simpleboot.c -o simpleboot_unstripped
zig objcopy -S simpleboot_unstripped simpleboot
chmod +x simpleboot
EXE=$PWD/simpleboot

# Build boot image
cd $ZIGROOT/sources
rm -rf iso
rm -f $ISO_PATH
mkdir iso
cp $ZIGROOT/boot/simpleboot.cfg iso/
cp $KERNEL_PATH iso/kernel
cp $INITRD_PATH iso/initramfs.cpio.gz

$EXE -vv -i initramfs.cpio.gz iso $ISO_PATH
