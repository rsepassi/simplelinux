#!/bin/sh
# Cross-compile Dropbear SSH using Zig.

set -e

TITLE="Building dropbear"
echo $TITLE

# Build zlib
cd $SLROOT/build/zlib
zig build-lib -target $ZIG_TARGET -O ReleaseFast \
    --name z \
    -cflags -std=c89 -- \
    adler32.c \
    compress.c \
    crc32.c \
    deflate.c \
    gzclose.c \
    gzlib.c \
    gzread.c \
    gzwrite.c \
    infback.c \
    inffast.c \
    inflate.c \
    inftrees.c \
    trees.c \
    uncompr.c \
    zutil.c \
    -lc
mkdir zlib-out
mv libz.a zlib-out
mv zlib.h zlib-out
mv zconf.h zlib-out
ldir=$PWD/zlib-out
idir=$PWD/zlib-out

# Limit parallelism. Hits segfaults if it is too high.
jn=$(nproc)
[ $jn -gt 8 ] && jn=8

cd $SLROOT/build/dropbear
export CC="zig cc -static --target=$ZIG_TARGET -L $ldir -I $idir"
./configure --enable-static --host=$ZIG_TARGET
make "-j$jn" PROGRAMS="dropbear scp" MULTI=1
zig objcopy -S dropbearmulti $DROPBEAR_PATH
chmod +x $DROPBEAR_PATH

echo "DONE: $TITLE"
