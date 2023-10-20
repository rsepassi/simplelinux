#!/bin/sh

set -e

. ./config.sh

MODE="${MODE:-kernel}"

echo "Launching qemu-system-$QEMU_ARCH"
echo "MODE (kernel, boot)=$MODE"
echo "QEMU_ARGS=$QEMU_ARGS"

echo "to interrupt: CTRL-]"
stty intr ^]

case "$MODE" in
  # Bootable disk image
  boot)
      echo "Running image $IMG_PATH with $QEMU_BIOS_ARG"
      qemu-system-$QEMU_ARCH \
        $QEMU_ARGS \
        $QEMU_BIOS_ARG \
        -m 256M \
        -serial stdio \
        -display none \
        -nic user,hostfwd=::8181-:22 \
        -drive format=raw,file=$IMG_PATH
      ;;

  # Kernel + initrd
  kernel)
      echo "Running kernel $KERNEL_PATH and initrd $INITRD_PATH"
      qemu-system-$QEMU_ARCH \
        $QEMU_ARGS \
        -m 256M \
        -serial stdio \
        -display none \
        -kernel $KERNEL_PATH \
        -initrd $INITRD_PATH \
        -nic user,hostfwd=::8181-:22 \
        -append "console=$QEMU_CONSOLE quiet loglevel=3"
      ;;

  *)
      echo "Unrecognized MODE $MODE"
      exit 1
      ;;
esac

stty intr ^C
