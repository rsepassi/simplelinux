#!/bin/sh
# Cross-compile BusyBox using Zig.

set -e

TITLE="Building busybox"
echo $TITLE

CROSS_PREFIX="bbcross"

setup_toolchain() {
  rm -rf toolchain
  mkdir toolchain

  # Zig doesn't properly handle these flags so we have to rewrite/ignore.
  # None of these affect the actual compilation target.
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
llvm-ar "\$@"
EOF
  chmod +x $local_ar

  local_gcc="toolchain/$CROSS_PREFIX-gcc"
  cat << EOF > $local_gcc
#!/bin/sh
$local_rewrite_utility

zig cc --target=$ZIG_ARCH-linux-$ZIG_ABI -fuse-ld=lld \
  \$(rewrite_flags "\$@")
EOF
  chmod +x $local_gcc

	export PATH="$PATH:$PWD/toolchain"
}

cd $SLROOT/sources/busybox
setup_toolchain
make clean
make defconfig HOSTCC="clang"
sed -i '/# CONFIG_STATIC is not set/c\CONFIG_STATIC=y' .config

# Limit parallelism. Hits segfaults if it is too high.
n=$(nproc)
m=16
if [ "$n" -gt "$m" ]
then
  jn=$m
else
  jn=$n
fi

CROSS_COMPILE="$CROSS_PREFIX-" make "-j$jn" busybox_unstripped
llvm-objcopy --strip-all busybox_unstripped busybox
chmod +x busybox

cp busybox $BUSYBOX_PATH

echo "DONE: $TITLE"
