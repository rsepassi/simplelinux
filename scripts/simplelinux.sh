#!/bin/sh
# Build simplelinux for $ARCH in an Alpine Linux container

DEBUG=${DEBUG:-0}

fail() {
  local_code=$1
  echo "ERROR: Build failed with status code $CODE. See log $log:"
  tail $log
  echo
  echo "ERROR: Build failed with status code $CODE. See log $log"
  exit $CODE
}

# Setup output and download cache directories
output_dir=$PWD/build/out/$ARCH
log=$output_dir/build_log.txt
cache_dir=$HOME/.cache/simplelinux
apk_cache_dir=$cache_dir/apkcache
[ "${DEBUG}" -eq 1 ] || rm -rf $output_dir
mkdir -p $output_dir
mkdir -p $cache_dir
mkdir -p $apk_cache_dir

# If DEBUG=1, drop into shell
if [ "${DEBUG}" -eq 1 ]
then
  echo "DEBUG enabled. Mounting current directory and dropping into shell"
  ARGS="-v $PWD:/root/simplelinux:rw"
  CMD="/bin/sh"
  REDIR="/dev/stdout"
else
  ARGS=""
  CMD="/root/simplelinux/scripts/build.sh"
  rm -rf $output_dir
  REDIR="$log"
fi
mkdir -p $output_dir
touch $log

echo
echo "simplelinux build"
echo
echo "start: $(date)"
echo "log: $log"

# Build our Alpine container
podman build -f scripts/Dockerfile -t simplelinux-build . > $REDIR
CODE=$?
if [ $CODE -ne 0 ]; then
  fail $CODE
fi

# Run
podman run -it \
  -e ARCH=$ARCH \
  -e KERNEL_CONFIG=$KERNEL_CONFIG \
  -e SSH_KEY="$SSH_KEY" \
  -v $output_dir:/root/simplelinux/build/out/$ARCH:rw \
  -v $cache_dir:/root/.cache/simplelinux:rw \
  -v $apk_cache_dir:/etc/apk/cache:rw \
  $ARGS \
  simplelinux-build \
  $CMD > $REDIR
CODE=$?
if [ $CODE -ne 0 ]; then
  fail $CODE
fi

echo "end:   $(date)"

echo "outputs: $output_dir"
ls -lh $output_dir | awk '{print $5, $9}'
echo
echo "simplelinux build complete"
echo
