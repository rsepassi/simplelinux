#!/bin/sh
set -e

TITLE="Building Linux kernel for $KERNEL_ARCH to $KERNEL_PATH"
echo $TITLE

cd sources/linux
cat << EOF > clangmake
#!/bin/sh
# https://docs.kernel.org/kbuild/llvm.html
make \
  LLVM=1 \
  ARCH=$KERNEL_ARCH \
  CC=clang \
  LD=ld.lld \
  AR=llvm-ar \
  NM=llvm-nm \
  STRIP=llvm-strip \
  OBJCOPY=llvm-objcopy \
  OBJDUMP=llvm-objdump \
  READELF=llvm-readelf \
  HOSTCC=clang \
  HOSTCXX=clang-c++ \
  HOSTAR=llvm-ar \
  HOSTLD=ld.lld \
  "\$@"
EOF

# Start fresh
./clangmake clean
echo "Linux cleaned"

# Configure
./clangmake defconfig
echo "Linux configured"

# Build
./clangmake "-j$BUILD_PARALLELISM"
echo "Linux built"

cp $KERNEL_SRC_PATH $KERNEL_PATH

echo "DONE: $TITLE"
