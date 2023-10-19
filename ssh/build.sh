#!/bin/sh

set -e

cd $SLROOT/sources/zig-zlib
zig build -Dtarget=$ZIG_TARGET
ldir=$PWD/zig-out/lib
idir=$PWD/zig-out/include

# Limit parallelism. Hits segfaults if it is too high.
n=$(nproc)
m=4
if [ "$n" -gt "$m" ]
then
  jn=$m
else
  jn=$n
fi

cd $SLROOT/sources/dropbear
make clean
export CC="zig cc -static --target=$ZIG_TARGET -L $ldir -I $idir"
./configure --enable-static --host=$ZIG_TARGET
make PROGRAMS="dropbear scp" MULTI=1
llvm-objcopy -S dropbearmulti $DROPBEAR_PATH
