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
RUN mkdir -p /root/build
ADD boot /root/build/boot
ADD busybox /root/build/busybox
ADD initrd /root/build/initrd
ADD kernel /root/build/kernel
ADD scripts /root/build/scripts
ADD build.sh /root/build/
ADD env.sh /root/build/

WORKDIR /root/build
