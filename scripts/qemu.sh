#!/bin/sh

echo "Launching qemu-system-$QEMU_ARCH"

echo "to interrupt: CTRL-]"
stty intr ^]

qemu-system-$QEMU_ARCH $QEMU_MACHINE_ARGS \
  -m 256M \
  -display none \
  -serial stdio \
  -drive format=raw,file=$ISO_PATH

stty intr ^C
