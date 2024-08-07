#!/bin/sh
# Build a bootable image. Uses the Limine bootloader.

set -e

TITLE="Building boot image to $IMG_PATH"
echo $TITLE

LIMINE_SRCDIR=$SLROOT/build/limine
BUILD=$LIMINE_SRCDIR/build
LIMINE=$BUILD/bin/limine
LIMINE_CFG_PATH=$SLROOT/boot/$LIMINE_CFG
BIOS=$BUILD/share/limine/limine-bios.sys
EFI=$BUILD/share/limine/$LIMINE_EFI_BIN
FAT=$BUILD/boot.img.fat
STARTUP_NSH=$BUILD/startup.nsh

rm -f $IMG_PATH
rm -f $IMG_PATH.gz
rm -rf $BUILD

mkdir -p $BUILD
cd $BUILD

# Build Limine
cd $LIMINE_SRCDIR
TOOLCHAIN_FOR_TARGET="llvm" \
  ./configure --prefix=$BUILD \
    --enable-uefi-$LIMINE_ARCH \
    --enable-bios
make "-j$BUILD_PARALLELISM" install
find $BUILD -type f | grep -v "/doc/" | grep -v "/man/"
cd $BUILD

# Build the bootable image.
#
# Format of the GPT-formatted disk image at $IMG_PATH
# See https://en.wikipedia.org/wiki/GUID_Partition_Table
#
# * Padded 1MiB preamble
#   * Protective MBR: contains bios bootloader
#   * Primary GPT metadata
#   * Padding
# * 1MiB - 63MiB: FAT32 EFI system partition
#     /EFI/BOOT/BOOT<ARCH>.EFI
#     /EFI/BOOT/startup.nsh
#     /boot/limine-bios.sys
#     /boot/limine.cfg
#     /kernel
#     /initrd
# * Padded 1MiB epilogue
#   * Padding
#   * Secondary GPT metadata

sector_size=512
fat_mb=62
fat_sectors=$(( ( fat_mb << 20 ) / sector_size ))
gpt_sectors=$(( ( ( fat_mb + 2 ) << 20 ) / sector_size ))
fat_offset=$(( ( 1 << 20 ) / sector_size ))

cat << EOF > $STARTUP_NSH
kernel initrd=initrd console=$QEMU_CONSOLE quiet loglevel=3
EOF

# Create and populate FAT32 partition
dd if=/dev/zero of=$FAT bs=$sector_size count=$fat_sectors
mformat -F -i $FAT ::
mmd -i $FAT ::/boot ::/EFI ::/EFI/BOOT
mcopy -i $FAT $EFI ::/EFI/BOOT/$LIMINE_EFI_BIN
mcopy -i $FAT $STARTUP_NSH ::/EFI/BOOT/startup.nsh
mcopy -i $FAT $BIOS ::/boot/limine-bios.sys
mcopy -i $FAT $LIMINE_CFG_PATH ::/boot/limine.cfg
mcopy -i $FAT $KERNEL_PATH ::/kernel
mcopy -i $FAT $KERNEL_PATH.config ::/kernel.config
mcopy -i $FAT $INITRD_PATH ::/initrd
mdir -i $FAT ::

# Make the GPT container
dd if=/dev/zero of=$IMG_PATH bs=$sector_size count=$gpt_sectors
end_str="$(( fat_mb + 1 ))MiB"
parted -s $IMG_PATH -- \
  unit MiB \
  mklabel gpt \
  mkpart primary fat32 1MiB $end_str \
  set 1 esp on
parted -s $IMG_PATH -- unit MiB print
dd if=$FAT of=$IMG_PATH bs=$sector_size seek=$fat_offset conv=notrunc

$LIMINE bios-install $IMG_PATH
gzip -9 -c $IMG_PATH > $IMG_PATH.gz

echo "DONE: $TITLE"
