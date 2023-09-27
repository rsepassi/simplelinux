#!/bin/sh
set -e

echo "Launching in Podman"

TMP=$(mktemp -d)
cat <<EOF > $TMP/init.sh
#!/bin/sh
busybox --install -s /usr/bin
exec /bin/sh
EOF
chmod +x $TMP/init.sh

tar -C $ZIGROOT/sources/rootfs -c . | podman import - zigroot
podman run \
        -v $TMP:/boot/podman:ro \
        -it zigroot \
        /boot/podman/init.sh
