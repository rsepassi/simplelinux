#!/bin/sh

set -e

ARCH=${ARCH:-$(uname -m)}
MODE="${MODE:-kernel}"
SSH_PORT="${SSH_PORT:-8181}"
MEM="${MEM:-"3G"}"
CPU="${CPU:-4}"

# Shared directory
DISK_ARG=""
if [ -n "$DATA_DIR" ]
then
  # In guest, run
  # mkdir /root/share
  # mount -t 9p -o trans=virtio vmshare /root/share -oversion=9p2000.L -o msize=268435456
  DISK_ARG="-virtfs local,path=$DATA_DIR,mount_tag=vmshare,security_model=mapped"
fi

# Shared disk
if [ -n "$DATA_DISK" ]
then
  # In guest, run
  #   mkdir /root/data
  #   mount /dev/vda /root/data
  # If fresh, must format first:
  #   fdisk /dev/vda
  #     > n
  #     > p
  #     > w
  #   mkfs.ext2 /dev/vda
  DISK_ARG="$DISK_ARG -drive file=$DATA_DISK,if=none,id=drive0 -device virtio-blk-pci,drive=drive0"
fi

INITRD_PATH=$PWD/build/out/$ARCH/initramfs.cpio.gz
KERNEL_PATH=$PWD/build/out/$ARCH/kernel

case "$ARCH" in
    x86)
        QEMU_ARCH="i386"
        QEMU_ARGS=""
        QEMU_BIOS_ARG="-bios /usr/share/qemu-efi-i386/OVMF-pure-efi.fd"
        QEMU_CONSOLE="ttyS0"
        QEMU_NIC="virtio-net-pci"
        ;;
    x86_64)
        QEMU_ARCH="x86_64"
        QEMU_ARGS=""
        QEMU_BIOS_ARG="-bios /usr/share/ovmf/OVMF.fd"
        QEMU_CONSOLE="ttyS0"
        QEMU_NIC="virtio-net-pci"
        ;;
    arm64)
        QEMU_ARCH="aarch64"
        QEMU_ARGS="-machine virt -cpu cortex-a53 -bios /usr/share/qemu-efi-aarch64/QEMU_EFI.fd"
        # MacOS M1
        # QEMU_ARGS="-machine virt,highmem=off -cpu cortex-a53 -bios /opt/homebrew/share/qemu/edk2-aarch64-code.fd -accel hvf"
        QEMU_BIOS_ARG=""  # already in QEMU_ARGS
        QEMU_CONSOLE="ttyS0"
        QEMU_NIC="virtio-net-pci"
        ;;
    riscv64)
        QEMU_ARCH="riscv64"
        QEMU_ARGS="-machine sifive_u"
        # TODO: Add UEFI firmware
        # https://github.com/riscv-admin/riscv-uefi-edk2-docs
        QEMU_BIOS_ARG=""
        QEMU_CONSOLE="ttySIF0"
        QEMU_NIC="cadence_gem"
        ;;
    arm)
        QEMU_ARCH="arm"
        QEMU_CONSOLE="ttyAMA0"
        QEMU_NIC="virtio-net-pci"
        QEMU_ARGS="-machine virt -cpu cortex-a15 -bios /usr/share/AAVMF/AAVMF32_CODE.fd"
        QEMU_BIOS_ARG=""  # already in QEMU_ARGS
        ;;
    *)
        echo "Unrecognized ARCH $ARCH"
        exit 1
esac


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
        $DISK_ARG \
        -m $MEM \
        -smp $CPU \
        -serial stdio \
        -display none \
        -nic user,hostfwd=::$SSH_PORT-:22,model=$QEMU_NIC \
        -drive format=raw,file=$IMG_PATH
      ;;

  # Kernel + initrd
  kernel)
      echo "Running kernel $KERNEL_PATH and initrd $INITRD_PATH"
      qemu-system-$QEMU_ARCH \
        $QEMU_ARGS \
        $DISK_ARG \
        -m $MEM \
        -smp $CPU \
        -serial stdio \
        -display none \
        -kernel $KERNEL_PATH \
        -initrd $INITRD_PATH \
        -nic user,hostfwd=::$SSH_PORT-:22,model=$QEMU_NIC \
        -append "console=$QEMU_CONSOLE quiet loglevel=3"
      ;;

  *)
      echo "Unrecognized MODE $MODE"
      exit 1
      ;;
esac

stty intr ^C
