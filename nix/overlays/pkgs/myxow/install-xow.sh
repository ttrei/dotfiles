#!/usr/bin/env sh

# Copy the necessary system files from nix store.
# Add systemd units to autostart xow.

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

BINDIR=$(dirname "$(readlink -f "$(which xow)")")
BASEDIR=$(realpath "$BINDIR/..")
UDEVDIR="$BASEDIR/lib/udev/rules.d"
MODLDIR="$BASEDIR/lib/modules-load.d"
MODPDIR="$BASEDIR/lib/modprobe.d"

sudo cp "$UDEVDIR/99-xow.rules" /etc/udev/rules.d/
sudo cp "$MODLDIR/xow-uinput.conf" /etc/modules-load.d/
sudo cp "$MODPDIR/xow-blacklist.conf" /etc/modprobe.d/

# I use my own xow.service because this one has a hardcoded nix-store path
#SYSDDIR="$BASEDIR/lib/systemd/system"
#sudo cp "$SYSDDIR/xow.service" /etc/systemd/system/
#sudo chmod 644 /etc/systemd/system/xow.service

sudo cp "$SCRIPT_DIR/xow-reset-xbox-wireless-dongle.sh" /sbin/
sudo cp "$SCRIPT_DIR/reset-xbox-wireless-dongle.service" /etc/systemd/system/
sudo cp "$SCRIPT_DIR/xow.service" /etc/systemd/system/

sudo systemctl enable reset-xbox-wireless-dongle.service
sudo systemctl enable xow.service

sudo ln -sf $(which xow) /usr/bin/xow
