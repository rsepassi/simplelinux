echo "Loading env.sh"

if [ -z "$ZIGROOT_ARCH" ]; then
    export ZIGROOT_ARCH="$(uname -m)"
fi
export BUSYBOX_VERSION="1.36.0"
export LINUX_VERSION="6.5"
export SIMPLEBOOT_VERSION="688312ba46aa830792c6369c1a938fe0eb3d58e4"

echo "=== Configuration ==="
echo "Architecture: $ZIGROOT_ARCH"
echo "Busybox: v$BUSYBOX_VERSION"
echo "Linux: v$LINUX_VERSION"
echo "Simpleboot: v$SIMPLEBOOT_VERSION"
echo "====================="

export ZIGROOT=$PWD
export PATH=$PATH:$ZIGROOT/zig-cross
export INITRD_PATH=$ZIGROOT/sources/initramfs.cpio
export ISO_PATH=$ZIGROOT/sources/zigroot.iso

case "$ZIGROOT_ARCH" in
    x86)
        export KERNEL_ARCH="i386"
        export KERNEL_PATH=$ZIGROOT/sources/linux/arch/$KERNEL_ARCH/boot/bzImage
        export QEMU_ARCH="i386"
        export QEMU_ARGS=""
        export ZIG_ARCH="x86"
        ;;
    x86_64)
        export KERNEL_ARCH="x86_64"
        export KERNEL_PATH=$ZIGROOT/sources/linux/arch/$KERNEL_ARCH/boot/bzImage
        export QEMU_ARCH="x86_64"
        export QEMU_ARGS=""
        export ZIG_ARCH="x86_64"
        ;;
    arm64)
        export KERNEL_ARCH="arm64"
        export KERNEL_PATH=$ZIGROOT/sources/linux/arch/$KERNEL_ARCH/boot/Image
        export QEMU_ARCH="aarch64"
        export QEMU_ARGS="-machine virt -cpu cortex-a53 -bios /usr/share/qemu-efi-aarch64/QEMU_EFI.fd"
        export ZIG_ARCH="aarch64"
        ;;
    riscv64)
        export KERNEL_ARCH="riscv"
        export KERNEL_PATH=$ZIGROOT/sources/linux/arch/$KERNEL_ARCH/boot/Image
        export QEMU_ARCH="riscv64"
        export QEMU_ARGS="-machine virt"
        export ZIG_ARCH="riscv64"
        ;;
    *)
        echo "Unrecognized ZIGROOT_ARCH $ZIGROOT_ARCH"
        exit 1
esac
