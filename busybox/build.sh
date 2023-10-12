#!/bin/sh
#
# This script statically compiles busybox using a Zig-based cross-compile
# toochain, which this script sets up.
#
# Zig is used here because of its ability to cleanly cross-compile; it packages
# within itself things that would otherwise need to be carefully setup on the
# host system (specifically OS headers and C libraries).

set -e

TITLE="Building busybox"
echo $TITLE

CROSS_PREFIX="bbcross"

setup_toolchain() {
  rm -rf toolchain
  mkdir toolchain

  # zig cc is almost, but not quite, a drop-in replacement for clang. These
  # flags need to be either rewritten or ignored for things to work. These do
  # not affect busybox functionality at all.
  local_rewrite_utility=$(cat << EOF
rewrite_flags() {
    transformed_args=""
    for arg in "\$@"; do
        case "\$arg" in
            -Wp,-MD,*)
                mfarg=\$(echo "\$arg" | sed 's/^-Wp,-MD,//')
                transformed_args="\${transformed_args} -MD -MF \${mfarg}"
                ;;
            -Wl,--warn-common)
                ;;
            -Wl,--verbose)
                ;;
            -Wl,-Map,*)
                ;;
             *)
                transformed_args="\${transformed_args} \${arg}"
        esac
    done
    echo "\$transformed_args"
}
EOF
)

  local_ar="toolchain/$CROSS_PREFIX-ar"
  cat << EOF > $local_ar
#!/bin/sh
echo "-- \$@ --" >> /tmp/arargs
zig ar "\$@"
EOF
  chmod +x $local_ar

  local_gcc="toolchain/$CROSS_PREFIX-gcc"
  cat << EOF > $local_gcc
#!/bin/sh

$local_rewrite_utility

if [ \$# -gt 0 ]
then
  zig cc --target=$ZIG_ARCH-linux-$ZIG_ABI -fuse-ld=lld \
    -Wno-unused-command-line-argument \
    -Wno-string-plus-int \
    -Wno-ignored-optimization-argument \
    -Wincompatible-pointer-types-discards-qualifiers \
    \$(rewrite_flags "\$@")
fi
EOF
  chmod +x $local_gcc

  local_hostcc="toolchain/$CROSS_PREFIX-hostcc"
  cat << EOF > $local_hostcc
#!/bin/sh

$local_rewrite_utility

if [ \$# -gt 0 ]
then
  zig cc \$(rewrite_flags "\$@")
fi
EOF
  chmod +x $local_hostcc

	export PATH="$PATH:$PWD/toolchain"
}

cd $ZIGROOT/sources/busybox
setup_toolchain
make clean
make defconfig HOSTCC="$CROSS_PREFIX-hostcc"

LDFLAGS="--static" \
CROSS_COMPILE="$CROSS_PREFIX-" \
make -j16 busybox_unstripped
zig objcopy -S busybox_unstripped busybox
chmod +x busybox

cp busybox $BUSYBOX_PATH

echo "DONE: $TITLE"
