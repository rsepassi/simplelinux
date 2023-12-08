#!/bin/sh
# Build the Linux kernel
set -e

TITLE="Building Linux kernel for $KERNEL_ARCH to $KERNEL_PATH"
echo $TITLE

cd $SLROOT/build/linux

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
chmod +x clangmake

# Start fresh
./clangmake clean
echo "Linux cleaned"

# Configure
if [ "$KERNEL_CONFIG" = "default" ]
then
  ./clangmake defconfig
else
  config=$SLROOT/linux/configs/$ARCH/$KERNEL_CONFIG
  echo "Using configuration $config"
  cp $config .config
fi
echo "Linux configured"

# Build
./clangmake "-j$BUILD_PARALLELISM"
echo "Linux built"

cp $KERNEL_SRC_PATH $KERNEL_PATH
cp .config $KERNEL_PATH.config

echo "DONE: $TITLE"
