#!/bin/sh

echo "Launching qemu-system-$QEMU_ARCH"
echo "QEMU_ARGS=$QEMU_ARGS"

echo "to interrupt: CTRL-]"
stty intr ^]

# With kernel and initrd
qemu-system-$QEMU_ARCH $QEMU_ARGS \
  -m 256M \
  -serial stdio \
  -display none \
  -kernel $KERNEL_PATH \
  -initrd $INITRD_PATH \
  -append "console=$QEMU_CONSOLE"

# With iso
# qemu-system-$QEMU_ARCH $QEMU_ARGS \
#   -m 256M \
#   -serial stdio \
#   -display none \
#   -drive format=raw,file=$ISO_PATH

# With x86_64 UEFI
# -bios /usr/share/ovmf/OVMF.fd \

# MicroVM for fast boot
# qemu-system-$QEMU_ARCH $QEMU_ARGS \
#   -m 256M \
#   -machine microvm \
#   -enable-kvm \
#   -serial stdio \
#   -display none \
#   -kernel $KERNEL_PATH \
#   -initrd $INITRD_PATH \
#   -append "$QEMU_CONSOLE"

stty intr ^C
