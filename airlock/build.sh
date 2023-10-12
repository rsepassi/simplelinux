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
  rm -rf sources
fi

echo $DEBUG
exit 1

mkdir -p sources
mkdir -p $HOME/.cache/simplelinux
podman build -f airlock/Dockerfile -t airlock .
podman run -it \
  -e ARCH=$ARCH \
  -v $PWD/sources:/root/simplelinux/sources:rw \
  -v $HOME/.cache/simplelinux:/root/.cache/simplelinux:ro \
  $ARGS \
  airlock $CMD
[ "$DEBUG" -eq 0 ] && ./scripts/qemu.sh
