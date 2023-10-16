echo "Loading env.sh"

ARCH=${ARCH:-$(uname -m)}
KERNEL_CONFIG=${KERNEL_CONFIG:-default}

export BUSYBOX_VERSION="1.36.0"
export LINUX_VERSION="6.5.7"
export LIMINE_VERSION="5.20231006.0"

export SLROOT=$PWD
export BUILD_DIR=$SLROOT/sources/build/$ARCH

ARCHS="x86 x86_64 arm arm64 riscv64"

echo "=== Configuration ==="
echo "Architecture ($ARCHS): $ARCH"
echo "Busybox: v$BUSYBOX_VERSION"
echo "Linux: v$LINUX_VERSION"
echo "Linux kernel config: $KERNEL_CONFIG"
echo "Limine: v$LIMINE_VERSION"
echo "Output directory: $BUILD_DIR"
echo "====================="

export INITRD_PATH=$BUILD_DIR/initramfs.cpio.gz
export INITRD_TAR_PATH=$BUILD_DIR/initramfs.tar.gz
export IMG_PATH=$BUILD_DIR/simplelinux.img
export KERNEL_PATH=$BUILD_DIR/kernel
export BUSYBOX_PATH=$BUILD_DIR/busybox

case "$ARCH" in
    x86)
        export KERNEL_ARCH="i386"
        export KERNEL_SRC_PATH=$SLROOT/sources/linux/arch/$KERNEL_ARCH/boot/bzImage
        export QEMU_ARCH="i386"
        export QEMU_ARGS=""
        export QEMU_BIOS_ARG="-bios /usr/share/qemu-efi-i386/OVMF-pure-efi.fd"
        export QEMU_CONSOLE="ttyS0"
        export ZIG_ARCH="x86"
        export ZIG_ABI="musl"
        export LIMINE_ARCH="ia32"
        export LIMINE_CFG="limine.cfg"
        export EFI_BIN="BOOTIA32.EFI"
        ;;
    x86_64)
        export KERNEL_ARCH="x86_64"
        export KERNEL_SRC_PATH=$SLROOT/sources/linux/arch/$KERNEL_ARCH/boot/bzImage
        export QEMU_ARCH="x86_64"
        export QEMU_ARGS=""
        export QEMU_BIOS_ARG="-bios /usr/share/ovmf/OVMF.fd"
        export QEMU_CONSOLE="ttyS0"
        export ZIG_ARCH="x86_64"
        export ZIG_ABI="musl"
        export LIMINE_ARCH="x86-64"
        export LIMINE_CFG="limine.cfg"
        export EFI_BIN="BOOTX64.EFI"
        ;;
    arm64)
        export KERNEL_ARCH="arm64"
        export KERNEL_SRC_PATH=$SLROOT/sources/linux/arch/$KERNEL_ARCH/boot/Image
        export QEMU_ARCH="aarch64"
        export QEMU_ARGS="-machine virt -cpu cortex-a53 -bios /usr/share/qemu-efi-aarch64/QEMU_EFI.fd"
        export QEMU_BIOS_ARG=""  # already in QEMU_ARGS
        export QEMU_CONSOLE="ttyS0"
        export ZIG_ARCH="aarch64"
        export ZIG_ABI="musl"
        export LIMINE_ARCH="aarch64"
        export LIMINE_CFG="limine_uefi.cfg"
        export EFI_BIN="BOOTAA64.EFI"
        ;;
    riscv64)
        export KERNEL_ARCH="riscv"
        export KERNEL_SRC_PATH=$SLROOT/sources/linux/arch/$KERNEL_ARCH/boot/Image
        export QEMU_ARCH="riscv64"
        export QEMU_ARGS="-machine virt"
        # TODO: Add UEFI firmware
        # https://github.com/riscv-admin/riscv-uefi-edk2-docs
        export QEMU_BIOS_ARG=""
        export QEMU_CONSOLE="ttyS0"
        export ZIG_ARCH="riscv64"
        export ZIG_ABI="musl"
        export LIMINE_ARCH="riscv64"
        export LIMINE_CFG="limine_uefi.cfg"
        export EFI_BIN="BOOTRISCV64.EFI"
        ;;
    arm)
        export KERNEL_ARCH="arm"
        export KERNEL_SRC_PATH=$SLROOT/sources/linux/arch/$KERNEL_ARCH/boot/zImage
        export QEMU_ARCH="arm"
        export QEMU_CONSOLE="ttyAMA0"
        export QEMU_ARGS="-machine virt -cpu cortex-a15 -bios /usr/share/AAVMF/AAVMF32_CODE.fd"
        export QEMU_BIOS_ARG=""  # already in QEMU_ARGS
        export LIMINE_CFG="limine_uefi.cfg"
        export ZIG_ARCH="arm"
        export ZIG_ABI="musleabihf"
        ;;
    *)
        echo "Unrecognized ARCH $ARCH"
        exit 1
esac
