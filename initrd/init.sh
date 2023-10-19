#!/bin/sh

set -e

initlog() {
  local_msg=$1
  if [ -e "/proc/uptime" ]
  then
    local_ms=$(awk '{print $1}' /proc/uptime)
  else
    local_ms="    "
  fi
  echo "== <init> == [$local_ms] $local_msg"
}

echo "== simplelinux init =="

/bin/busybox --install -s /bin

dmesg -n 3

initlog "pseudo-filesystems"
mkdir -p /proc
mount -t proc proc /proc
mkdir -p /sys
mount -t sysfs sysfs /sys
mkdir -p /dev
mount -t devtmpfs devtmpfs /dev
mkdir -p /dev/shm
mount -t tmpfs tmpfs /dev/shm
mkdir -p /dev/pts
mount -t devpts devpts /dev/pts

initlog "syslogd"
syslogd -Dt -C500

initlog "ntpd"
ntpd -p 0.pool.ntp.org -p 1.pool.ntp.org -p 2.pool.ntp.org

initlog "crond"
crond

initlog "networking"
hostname -F /etc/hostname
udhcpc -i eth0 -S -s /etc/udhcp/simple.script >/dev/null 2>&1

initlog "ssh"
dropbear -sg -R

initlog "simplelinux init complete"

# Our humble welcome banner
echo "


      ====== simplelinux ======


"
