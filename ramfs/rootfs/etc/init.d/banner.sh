#!/bin/sh

boot=$(cat /proc/uptime | cut -d' ' -f1)

echo "


      ====== simplelinux ======


"
echo "booted in $boot seconds"
