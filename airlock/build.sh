#!/bin/bash

set -e

ARGS=""
CMD="/root/build/build.sh"

if [ -v DEBUG ] && [ "$DEBUG" -eq 1 ]
then
  echo "DEBUG enabled. Mounting current directory and dropping into shell"
  ARGS="-v $PWD:/root/build"
  CMD="/bin/sh"
else
  rm -rf sources
  DEBUG=0
fi

mkdir -p sources
podman build -f airlock/Dockerfile -t airlock .
podman run -it \
  -e ZIGROOT_ARCH=$ZIGROOT_ARCH \
  -v $PWD/sources:/root/build/sources:rw \
  -v $HOME/.cache/zigroot:/root/.cache/zigroot:ro \
  $ARGS \
  airlock $CMD
[ "$DEBUG" -eq 0 ] && ./scripts/qemu.sh
