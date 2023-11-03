#!/bin/sh
# Cross-compile Dropbear SSH using Zig.

set -e

TITLE="Building dropbear"
echo $TITLE

# Build zlib
cd $SLROOT/build/zlib
cp $SLROOT/ssh/zlib_build.zig build.zig
zig build -Dtarget=$ZIG_TARGET
ldir=$PWD/zig-out/lib
idir=$PWD/zig-out/include

# Limit parallelism. Hits segfaults if it is too high.
n=$(nproc)
m=8
if [ "$n" -gt "$m" ]
then
  jn=$m
else
  jn=$n
fi

cd $SLROOT/build/dropbear
export CC="zig cc -static --target=$ZIG_TARGET -L $ldir -I $idir"
./configure --enable-static --host=$ZIG_TARGET
make "-j$jn" PROGRAMS="dropbear scp" MULTI=1
zig objcopy -S dropbearmulti $DROPBEAR_PATH
chmod +x $DROPBEAR_PATH

echo "DONE: $TITLE"
