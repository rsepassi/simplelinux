#!/bin/sh

set -e

ARCH=${ARCH:-$(uname -m)}
SRC=sources/build/$ARCH/initramfs.tar.gz

echo "Launching $SRC in Podman"

TMP=$(mktemp -d)
cat <<EOF > $TMP/init.sh
#!/bin/sh
echo simplelinux Podman init
busybox --install -s /usr/bin
HOME=/root
exec /bin/sh
EOF
chmod +x $TMP/init.sh

podman import $SRC simplelinux
podman run \
        -v $TMP:/boot/podman:ro \
        -it simplelinux \
        /boot/podman/init.sh
