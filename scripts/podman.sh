#!/bin/sh

set -e

echo "Launching in Podman"

TMP=$(mktemp -d)
cat <<EOF > $TMP/init.sh
#!/bin/sh
echo simplelinux Podman init
busybox --install -s /usr/bin
HOME=/root
exec /bin/sh
EOF
chmod +x $TMP/init.sh

podman import sources/build/initramfs.tar.gz simplelinux
podman run \
        -v $TMP:/boot/podman:ro \
        -it simplelinux \
        /boot/podman/init.sh
