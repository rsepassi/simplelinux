#!/bin/sh

set -e

initlog() {
  local_msg=$1
  echo "== <init> == [$(awk '{print $1}' /proc/uptime)] $local_msg"
}

echo "== simplelinux init =="

/bin/busybox --install -s /bin

dmesg -n 3

mkdir -p /proc
mount -t proc none /proc
mkdir -p /sys
mount -t sysfs none /sys
mkdir -p /dev
mount -t devtmpfs none /dev
mkdir -p /dev/shm
mount -t tmpfs none /dev/shm
mkdir -p /dev/pts
mount -t devpts none /dev/pts
initlog "Pseudo-filesystems setup"

syslogd -Dt -C500
initlog "syslogd setup"

ntpd -p 0.pool.ntp.org -p 1.pool.ntp.org -p 2.pool.ntp.org
initlog "ntpd setup"

crond
initlog "crond setup"

hostname -F /etc/hostname
udhcpc -i eth0 -S -s /etc/udhcp/simple.script >/dev/null 2>&1
initlog "Networking setup"

dropbear -sgjk -R
initlog "SSH setup"

initlog "simplelinux init complete"

# Our humble welcome banner
echo "


      ====== simplelinux ======


"
