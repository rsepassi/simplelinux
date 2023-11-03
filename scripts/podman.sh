#!/bin/sh
# Run initramfs.tar.gz in a Podman container

set -e

ARCH=${ARCH:-$(uname -m)}
SRC=$PWD/build/out/$ARCH/initramfs.tar.gz

echo "Launching $SRC in Podman"

TMP=$(mktemp -d)
mkdir $TMP/boot
cat <<EOF > $TMP/boot/init.sh
#!/bin/sh
echo
echo "   === simplelinux ==="
echo

busybox --install -s /usr/bin

export USER=root
export HOME=/root

exec /bin/sh
EOF
chmod +x $TMP/boot/init.sh

podman import $SRC simplelinux
podman run \
        -v $TMP/boot:/boot/podman:ro \
        -it simplelinux \
        /boot/podman/init.sh

rm -rf $TMP
