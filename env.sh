echo "Loading env.sh"

export ZIGROOT_ARCH="x86_64"  # {x86_64, x86, arm64}
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
export INITRD_PATH=$ZIGROOT/sources/initramfs.cpio.gz
export ISO_PATH=$ZIGROOT/sources/zigroot.iso

case "$ZIGROOT_ARCH" in
    x86)
        export KERNEL_ARCH="i386"
        export KERNEL_PATH=$ZIGROOT/sources/linux/arch/$KERNEL_ARCH/boot/bzImage
        export QEMU_ARCH="i386"
        export QEMU_MACHINE_ARGS=""
        ;;
    x86_64)
        export KERNEL_ARCH="x86_64"
        export KERNEL_PATH=$ZIGROOT/sources/linux/arch/$KERNEL_ARCH/boot/bzImage
        export QEMU_ARCH="x86_64"
        export QEMU_MACHINE_ARGS=""
        ;;
    arm64)
        export KERNEL_ARCH="arm64"
        export KERNEL_PATH=$ZIGROOT/sources/linux/arch/$KERNEL_ARCH/boot/Image
        export QEMU_ARCH="aarch64"
        export QEMU_MACHINE_ARGS="-machine virt -cpu cortex-a57"
        ;;
    *)
        echo "Unrecognized ZIGROOT_ARCH $ZIGROOT_ARCH"
        exit 1
esac
