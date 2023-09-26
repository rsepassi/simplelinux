#!/bin/sh
qemu-system-aarch64 \
  -machine virt \
  -cpu cortex-a57 \
  -m 4G \
  -display none \
  -serial stdio \
  -initrd /tmp/initramfs.cpio \
  -kernel sources/linux/linux-6.5/arch/arm64/boot/Image
