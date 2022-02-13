#!/usr/bin/env sh

BINDIR=$(dirname "$(readlink -f "$(which xow)")")
BASEDIR=$(realpath "$BINDIR/..")
UDEVDIR="$BASEDIR/lib/udev/rules.d"
MODLDIR="$BASEDIR/lib/modules-load.d"
MODPDIR="$BASEDIR/lib/modprobe.d"
SYSDDIR="$BASEDIR/lib/systemd/system"

sudo cp "$UDEVDIR/99-xow.rules" /etc/udev/rules.d/
sudo cp "$MODLDIR/xow-uinput.conf" /etc/modules-load.d/
sudo cp "$MODPDIR/xow-blacklist.conf" /etc/modprobe.d/
sudo cp "$SYSDDIR/xow.service" /etc/systemd/system/
