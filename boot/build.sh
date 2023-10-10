#!/bin/sh
set -e

TITLE="Building boot image to $IMG_PATH"
echo $TITLE

LIMINE_SRCDIR=$ZIGROOT/sources/limine
BUILD=$LIMINE_SRCDIR/build
LIMINE=$BUILD/bin/limine
LIMINE_CFG=$ZIGROOT/boot/limine.cfg
BIOS=$BUILD/share/limine/limine-bios.sys
EFI=$BUILD/share/limine/$EFI_BIN
FAT=$BUILD/boot.img.fat

rm -f $IMG_PATH
rm -rf $BUILD

mkdir -p $BUILD
cd $BUILD

setup_toolchain() {
	rm -rf $BUILD/toolchain
	mkdir $BUILD/toolchain

	local_tools="
	llvm-addr2line
	llvm-ar
	clang
	clang++
	llvm-cxxfilt
	ld.lld
	llvm-nm
	llvm-objcopy
	llvm-objdump
	llvm-readelf
	llvm-size
	llvm-strings
	llvm-strip
	"

	for local_tool in $local_tools
	do
		local_full="$local_tool-16"
		local_path=$(which $local_full)
		ln -s $local_path $BUILD/toolchain/$local_tool
	done
	export PATH="$PATH:$BUILD/toolchain"
}

build_limine() {
  cd $LIMINE_SRCDIR
  setup_toolchain
	TOOLCHAIN_FOR_TARGET="llvm" \
		./configure --prefix=$BUILD \
		--enable-uefi-$LIMINE_ARCH \
		--enable-bios
	make -j64 install
	find $BUILD -type f | grep -v "/doc/" | grep -v "/man/"
  cd $BUILD
}

build_limine

# Format of the GPT-formatted disk image at $IMG_PATH
# See https://en.wikipedia.org/wiki/GUID_Partition_Table
#
# * Padded 1MiB preamble
#   * Protective MBR: contains bios bootloader
#   * Primary GPT metadata
#   * Padding
# * 1MiB - 63MiB: FAT32 EFI system partition
#     /EFI/BOOT/BOOT<ARCH>.EFI
#     /boot/limine-bios.sys
#     /boot/limine.cfg
#     /kernel
#     /initrd
# * Padded 1MiB epilogue
#   * Padding
#   * Secondary GPT metadata

sector_size=512
fat_mb=62
fat_sectors=$(( ( fat_mb << 20 ) / 512 ))
gpt_sectors=$(( ( ( fat_mb + 2 ) << 20 ) / 512 ))
fat_offset=$(( ( 1 << 20 ) / 512 ))

# Create and populate FAT32 partition
dd if=/dev/zero of=$FAT bs=$sector_size count=$fat_sectors
mformat -F -i $FAT ::
mmd -i $FAT ::/boot ::/EFI ::/EFI/BOOT
mcopy -i $FAT $EFI ::/EFI/BOOT/$EFI_BIN
mcopy -i $FAT $BIOS ::/boot/limine-bios.sys
mcopy -i $FAT $LIMINE_CFG ::/boot/limine.cfg
mcopy -i $FAT $KERNEL_PATH ::/kernel
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

echo "DONE: $TITLE"
