#!/bin/sh

set -e

echo "Launching qemu-system-$QEMU_ARCH"
echo "QEMU_ARGS=$QEMU_ARGS"

echo "to interrupt: CTRL-]"
stty intr ^]

case "$QEMU_RUN_MODE" in
  # Bootable disk image
  img)
      qemu-system-$QEMU_ARCH \
        $QEMU_ARGS \
        $QEMU_BIOS_ARG \
        -m 256M \
        -serial stdio \
        -display none \
        -drive format=raw,file=$IMG_PATH
      ;;

  # Kernel + initrd
  kernel)
      qemu-system-$QEMU_ARCH \
        $QEMU_ARGS \
        -m 256M \
        -serial stdio \
        -display none \
        -kernel $KERNEL_PATH \
        -initrd $INITRD_PATH \
        -append "console=$QEMU_CONSOLE"
      ;;

  # microvm + KVM
  microvm)
      qemu-system-$QEMU_ARCH \
        $QEMU_ARGS \
        -m 256M \
        -machine microvm \
        -enable-kvm \
        -serial stdio \
        -display none \
        -kernel $KERNEL_PATH \
        -initrd $INITRD_PATH \
        -append "console=$QEMU_CONSOLE"
      ;;

  *)
      echo "Unrecognized QEMU_RUN_MODE $QEMU_RUN_MODE"
      exit 1
      ;;
esac

stty intr ^C
