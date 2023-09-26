#!/bin/sh
set -e

export ZIGROOT=$PWD

# sources
./download.sh

# busybox
./busybox/build.sh

# kernel
./kernel/build.sh

# ramfs
./initrd/build.sh

# run
./qemu.sh
