echo "Loading env.sh"

if [ -z "$ZIGROOT_ARCH" ]; then
    export ZIGROOT_ARCH="$(uname -m)"
fi
if [ -z "$QEMU_RUN_MODE" ]; then
    export QEMU_RUN_MODE="kernel"
fi
export BUSYBOX_VERSION="1.36.0"
export LINUX_VERSION="6.5"
export LIMINE_VERSION="5.20231006.0"

ARCHS="x86 x86_64 arm64 riscv64"
QEMU_MODES="img kernel microvm"

echo "=== Configuration ==="
echo "Architecture ($ARCHS): $ZIGROOT_ARCH"
echo "QEMU run mode ($QEMU_MODES): $QEMU_RUN_MODE"
echo "Busybox: v$BUSYBOX_VERSION"
echo "Linux: v$LINUX_VERSION"
echo "Limine: v$LIMINE_VERSION"
echo "====================="

export ZIGROOT=$PWD
export PATH=$PATH:$ZIGROOT/zig-cross
export INITRD_PATH=$ZIGROOT/sources/initramfs.cpio.gz
export IMG_PATH=$ZIGROOT/sources/zigroot.img

case "$ZIGROOT_ARCH" in
    x86)
        export KERNEL_ARCH="i386"
        export KERNEL_PATH=$ZIGROOT/sources/linux/arch/$KERNEL_ARCH/boot/bzImage
        export QEMU_ARCH="i386"
        export QEMU_ARGS=""
        export QEMU_CONSOLE="ttyS0"
        # TODO
        # export QEMU_BIOS_ARG="-bios /usr/share/ovmf/OVMF.fd"
        export ZIG_ARCH="x86"
        export ZIG_ABI="musl"
        export LIMINE_ARCH="ia32"
        export EFI_BIN="BOOTIA32.EFI"
        ;;
    x86_64)
        export KERNEL_ARCH="x86_64"
        export KERNEL_PATH=$ZIGROOT/sources/linux/arch/$KERNEL_ARCH/boot/bzImage
        export QEMU_ARCH="x86_64"
        export QEMU_ARGS=""
        export QEMU_BIOS_ARG="-bios /usr/share/ovmf/OVMF.fd"
        export QEMU_CONSOLE="ttyS0"
        export ZIG_ARCH="x86_64"
        export ZIG_ABI="musl"
        export LIMINE_ARCH="x86-64"
        export EFI_BIN="BOOTX64.EFI"
        ;;
    arm64)
        export KERNEL_ARCH="arm64"
        export KERNEL_PATH=$ZIGROOT/sources/linux/arch/$KERNEL_ARCH/boot/Image
        export QEMU_ARCH="aarch64"
        export QEMU_ARGS="-machine virt -cpu cortex-a53 -bios /usr/share/qemu-efi-aarch64/QEMU_EFI.fd"
        export QEMU_BIOS_ARG=""  # already in QEMU_ARGS
        export QEMU_CONSOLE="ttyS0"
        export ZIG_ARCH="aarch64"
        export ZIG_ABI="musl"
        export LIMINE_ARCH="aarch64"
        export EFI_BIN="BOOTAA64.EFI"
        ;;
    riscv64)
        export KERNEL_ARCH="riscv"
        export KERNEL_PATH=$ZIGROOT/sources/linux/arch/$KERNEL_ARCH/boot/Image
        export QEMU_ARCH="riscv64"
        export QEMU_ARGS="-machine virt"
        # TODO
        # export QEMU_BIOS_ARG=""
        export QEMU_CONSOLE="ttyS0"
        export ZIG_ARCH="riscv64"
        export ZIG_ABI="musl"
        export LIMINE_ARCH="riscv64"
        export EFI_BIN="BOOTRISCV64.EFI"
        ;;
    # Note: Limine does not support arm 32-bit
    # arm)
    #     export KERNEL_ARCH="arm"
    #     export KERNEL_PATH=$ZIGROOT/sources/linux/arch/$KERNEL_ARCH/boot/zImage
    #     export QEMU_ARCH="arm"
    #     export QEMU_CONSOLE="ttyAMA0"
    #     export QEMU_ARGS="-machine virt -cpu cortex-a15 -bios /usr/share/AAVMF/AAVMF32_CODE.fd"
    #     export QEMU_BIOS_ARG=""  # already in QEMU_ARGS
    #     export ZIG_ARCH="arm"
    #     export ZIG_ABI="musleabihf"
    #     ;;
    *)
        echo "Unrecognized ZIGROOT_ARCH $ZIGROOT_ARCH"
        exit 1
esac
