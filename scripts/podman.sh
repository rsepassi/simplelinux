#!/bin/sh

set -e

ARCH=${ARCH:-$(uname -m)}
SRC=$PWD/sources/build/$ARCH/initramfs.tar.gz

echo "Launching $SRC in Podman"

TMP=$(mktemp -d)
mkdir $TMP/boot
cat <<EOF > $TMP/boot/init.sh
#!/bin/sh
echo "simplelinux Podman init"

busybox --install -s /usr/bin

export USER=root
export HOME=/root

dropbear -sg -R

exec /bin/sh
EOF
chmod +x $TMP/boot/init.sh

podman import $SRC simplelinux
podman run \
        -v $TMP/boot:/boot/podman:ro \
        -it simplelinux \
        /boot/podman/init.sh
