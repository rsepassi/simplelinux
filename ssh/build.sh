#!/bin/sh

set -e

TITLE="Building dropbear"
echo $TITLE

cd $SLROOT/sources/zig-zlib
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

cd $SLROOT/sources/dropbear
export CC="zig cc -Wno-undef -static --target=$ZIG_TARGET -L $ldir -I $idir"
./configure --enable-static --host=$ZIG_TARGET
make clean
make "-j$jn" PROGRAMS="dropbear scp" MULTI=1
llvm-objcopy -S dropbearmulti $DROPBEAR_PATH

echo "DONE: $TITLE"
