#!/bin/sh

set -e

if [ "${DEBUG}" = "1" ]
then
  echo "DEBUG enabled. Mounting current directory and dropping into shell"
  ARGS="-v $PWD:/root/simplelinux"
  CMD="/bin/sh"
else
  ARGS=""
  CMD="/root/simplelinux/build.sh"
  DEBUG=0
  rm -rf sources/build/$ARCH
fi

mkdir -p sources/build/$ARCH
mkdir -p $HOME/.cache/simplelinux
podman build -f airlock/Dockerfile -t airlock .
podman run -it \
  -e ARCH=$ARCH \
  -v $PWD/sources/build/$ARCH:/root/simplelinux/sources/build/$ARCH:rw \
  -v $HOME/.cache/simplelinux:/root/.cache/simplelinux:ro \
  $ARGS \
  airlock $CMD
[ "$DEBUG" -eq 0 ] && ./scripts/qemu.sh
