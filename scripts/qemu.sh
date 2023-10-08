#!/bin/sh

echo "Launching qemu-system-$QEMU_ARCH"

echo "to interrupt: CTRL-]"
stty intr ^]

qemu-system-$QEMU_ARCH $QEMU_MACHINE_ARGS \
  -m 256M \
  -serial stdio \
  -display none \
  -drive format=raw,file=$ISO_PATH

# With UEFI
# -bios /usr/share/ovmf/OVMF.fd \

# Standard QEMU
# qemu-system-$QEMU_ARCH $QEMU_MACHINE_ARGS \
#   -m 256M \
#   -serial stdio \
#   -display none \
#   -kernel $KERNEL_PATH \
#   -initrd $INITRD_PATH \
#   -append "console=ttyS0"

# MicroVM for fast boot
# qemu-system-$QEMU_ARCH $QEMU_MACHINE_ARGS \
#   -m 256M \
#   -machine microvm \
#   -enable-kvm \
#   -serial stdio \
#   -display none \
#   -kernel $KERNEL_PATH \
#   -initrd $INITRD_PATH \
#   -append "console=ttyS0"

stty intr ^C
