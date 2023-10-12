FROM alpine:3.18

WORKDIR /root

# Dependencies
RUN apk update
RUN apk add make llvm16 clang16 musl-dev lld  # compiler toolchain
RUN wget https://ziglang.org/download/0.11.0/zig-linux-x86_64-0.11.0.tar.xz && \
    tar xf zig-linux-x86_64-0.11.0.tar.xz && \
    ln -s /root/zig-linux-x86_64-0.11.0/zig /usr/local/bin/zig && \
    rm zig-linux-x86_64-0.11.0.tar.xz  # zig, for busybox cross-compile
RUN apk add linux-headers flex bison elfutils-dev openssl-dev perl rsync  # for linux
RUN apk add nasm mtools parted  # for boot image

# Add in build files
RUN mkdir -p /root/simplelinux
ADD boot /root/simplelinux/boot
ADD busybox /root/simplelinux/busybox
ADD initrd /root/simplelinux/initrd
ADD kernel /root/simplelinux/kernel
ADD scripts /root/simplelinux/scripts
ADD build.sh /root/simplelinux/
ADD env.sh /root/simplelinux/

WORKDIR /root/simplelinux
