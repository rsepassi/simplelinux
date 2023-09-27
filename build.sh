#!/bin/sh
set -e

. ./env.sh

# sources
./scripts/download.sh

# busybox
./busybox/build.sh

# kernel
./kernel/build.sh

# ramfs
./initrd/build.sh

# bootloader
./boot/build.sh

# run
./scripts/qemu.sh
