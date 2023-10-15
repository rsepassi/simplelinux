#!/bin/sh

set -e

DEBUG=${DEBUG:-0}
QEMU=${QEMU:-0}

OUTPUT_DIR=$PWD/sources/build/$ARCH
CACHE_DIR=$HOME/.cache/simplelinux

if [ "${DEBUG}" -eq 1 ]
then
  echo "DEBUG enabled. Mounting current directory and dropping into shell"
  ARGS="-v $PWD:/root/simplelinux:rw"
  CMD="/bin/sh"
else
  ARGS=""
  CMD="/root/simplelinux/build.sh"
fi

[ "${DEBUG}" -eq 1 ] || rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR
mkdir -p $CACHE_DIR

podman build -f airlock/Dockerfile -t airlock .

podman run -it \
  -e ARCH=$ARCH \
  -v $OUTPUT_DIR:/root/simplelinux/sources/build/$ARCH:rw \
  -v $CACHE_DIR:/root/.cache/simplelinux:rw \
  $ARGS \
  airlock \
  $CMD

echo "Output directory: $OUTPUT_DIR"
ls -lh $OUTPUT_DIR

[ "${QEMU}" -eq 1 ] && ./scripts/qemu.sh
