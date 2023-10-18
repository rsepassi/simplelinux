#!/bin/sh

set -e

. ./env.sh

QEMU_RUN_MODE="${MODE:-kernel}"

echo "Launching qemu-system-$QEMU_ARCH"
echo "QEMU_ARGS=$QEMU_ARGS"
echo "MODE=$QEMU_RUN_MODE"

echo "to interrupt: CTRL-]"
stty intr ^]

case "$QEMU_RUN_MODE" in
  # Bootable disk image
  img)
      echo "Running image $IMG_PATH with $QEMU_BIOS_ARG"
      qemu-system-$QEMU_ARCH \
        $QEMU_ARGS \
        $QEMU_BIOS_ARG \
        -m 256M \
        -serial stdio \
        -display none \
        -nic user,hostfwd=::8181-:22,model=virtio-net-pci \
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
        -nic user,hostfwd=::8181-:22,model=virtio-net-pci \
        -append "console=$QEMU_CONSOLE quiet loglevel=3"
      ;;

  # microvm + KVM
  microvm)
      echo "Running kernel $KERNEL_PATH and initrd $INITRD_PATH on microvm"
      qemu-system-$QEMU_ARCH \
        $QEMU_ARGS \
        -m 256M \
        -machine microvm \
        -enable-kvm \
        -serial stdio \
        -display none \
        -kernel $KERNEL_PATH \
        -initrd $INITRD_PATH \
        -nic user,hostfwd=::8181-:22,model=virtio-net-pci \
        -append "console=$QEMU_CONSOLE quiet loglevel=3"
      ;;

  *)
      echo "Unrecognized QEMU_RUN_MODE $QEMU_RUN_MODE"
      exit 1
      ;;
esac

stty intr ^C
