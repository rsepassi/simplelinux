echo "Loading config.sh"

ARCH=${ARCH:-$(uname -m)}
KERNEL_CONFIG=${KERNEL_CONFIG:-default}

export BUSYBOX_VERSION="1.36.0"
export LINUX_VERSION="6.6.2"
export LIMINE_VERSION="5.20231006.0"
export DROPBEAR_VERSION="2022.83"
export ZLIB_VERSION="1.3"
export ZIG_VERSION="0.11.0"

export SLROOT=$PWD
export BUILD_DIR=$SLROOT/build/out/$ARCH

ARCHS="x86 x86_64 arm arm64 riscv64"

echo "=== Configuration ==="
echo "Architecture ($ARCHS): $ARCH"
echo "Busybox: v$BUSYBOX_VERSION"
echo "Linux: v$LINUX_VERSION"
echo "Linux kernel config: $KERNEL_CONFIG"
echo "Limine: v$LIMINE_VERSION"
echo "Dropbear: v$DROPBEAR_VERSION"
echo "zlib: v$ZLIB_VERSION"
echo "Output directory: $BUILD_DIR"
echo "====================="

export INITRD_PATH=$BUILD_DIR/initramfs.cpio.gz
export INITRD_TAR_PATH=$BUILD_DIR/initramfs.tar.gz
export IMG_PATH=$BUILD_DIR/simplelinux.img
export KERNEL_PATH=$BUILD_DIR/kernel
export BUSYBOX_PATH=$BUILD_DIR/busybox
export DROPBEAR_PATH=$BUILD_DIR/dropbearmulti

# Limit parallelism. Hits segfaults if it is too high within Podman.
n=$(nproc)
m=16
if [ "$n" -gt "$m" ]
then
  jn=$m
else
  jn=$n
fi
export BUILD_PARALLELISM=$jn

case "$ARCH" in
    x86)
        export KERNEL_ARCH="i386"
        export KERNEL_SRC_PATH=$SLROOT/build/linux/arch/$KERNEL_ARCH/boot/bzImage
        export ZIG_TARGET="x86-linux-musl"
        export LIMINE_CFG="limine.cfg"
        export LIMINE_ARCH="ia32"
        export LIMINE_EFI_BIN="BOOTIA32.EFI"
        export QEMU_CONSOLE="ttyS0"
        ;;
    x86_64)
        export KERNEL_ARCH="x86_64"
        export KERNEL_SRC_PATH=$SLROOT/build/linux/arch/$KERNEL_ARCH/boot/bzImage
        export ZIG_TARGET="x86_64-linux-musl"
        export LIMINE_CFG="limine.cfg"
        export LIMINE_ARCH="x86-64"
        export LIMINE_EFI_BIN="BOOTX64.EFI"
        export QEMU_CONSOLE="ttyS0"
        ;;
    arm)
        export KERNEL_ARCH="arm"
        export KERNEL_SRC_PATH=$SLROOT/build/linux/arch/$KERNEL_ARCH/boot/zImage
        export ZIG_TARGET="arm-linux-musleabihf"
        export LIMINE_CFG="limine_uefi.cfg"
        export QEMU_CONSOLE="ttyAMA0"
        ;;
    arm64)
        export KERNEL_ARCH="arm64"
        export KERNEL_SRC_PATH=$SLROOT/build/linux/arch/$KERNEL_ARCH/boot/Image
        export ZIG_TARGET="aarch64-linux-musl"
        export LIMINE_CFG="limine_uefi.cfg"
        export LIMINE_ARCH="aarch64"
        export LIMINE_EFI_BIN="BOOTAA64.EFI"
        export QEMU_CONSOLE="ttyS0"
        ;;
    riscv64)
        export KERNEL_ARCH="riscv"
        export KERNEL_SRC_PATH=$SLROOT/build/linux/arch/$KERNEL_ARCH/boot/Image
        export ZIG_TARGET="riscv64-linux-musl"
        export LIMINE_CFG="limine_uefi.cfg"
        export LIMINE_ARCH="riscv64"
        export LIMINE_EFI_BIN="BOOTRISCV64.EFI"
        export QEMU_CONSOLE="ttySIF0"
        ;;
    *)
        echo "Unrecognized ARCH $ARCH"
        exit 1
esac
