FROM alpine:3.18

WORKDIR /root

# Dependencies
RUN apk update
RUN apk add make llvm16 clang16 musl-dev lld  # compiler toolchain
RUN apk add linux-headers flex bison elfutils-dev openssl-dev perl rsync \
            ncurses-dev  # for linux
RUN apk add nasm mtools parted  # for boot image
RUN apk add zig \
      --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing  # for busybox+dropbear cross-compilation

# Add in build files
RUN mkdir -p /root/simplelinux
ADD boot /root/simplelinux/boot
ADD busybox /root/simplelinux/busybox
ADD kernel /root/simplelinux/kernel
ADD initrd /root/simplelinux/initrd
ADD ssh /root/simplelinux/ssh
ADD scripts /root/simplelinux/scripts
ADD build.sh /root/simplelinux/
ADD env.sh /root/simplelinux/

WORKDIR /root/simplelinux
