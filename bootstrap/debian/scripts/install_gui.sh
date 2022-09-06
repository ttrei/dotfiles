#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ -z "$BOOTSTRAP_BASEDIR" ]]; then
    echo "BOOTSTRAP_BASEDIR not set" 1>&2
    exit 1
fi

sudo DEBIAN_FRONTEND=noninteractive apt-get update -q
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -q -y
sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -q -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y --no-install-recommends \
x11-xserver-utils \
xserver-xorg-core \
xserver-xorg-input-all \
xserver-xorg-input-evdev \
xserver-xorg-video-fbdev

sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
default-jdk-headless \
dmenu \
dunst \
evince \
feh \
firefox-esr \
fonts-font-awesome \
gitk \
i3-wm \
libfreetype6-dev \
libglew-dev \
libglm-dev \
libsdl2-dev \
libsdl2-image-dev \
libsdl2-ttf-dev \
lightdm \
obs-studio \
pavucontrol \
pulseaudio \
qemu-system-x86 \
redshift \
rofi \
virt-viewer \
xdotool \
xfce4-terminal \
xinit \
xsel \
#xbindkeys
#qtcreator
#default-jre

sudo cp "$BOOTSTRAP_BASEDIR/files/lv-reinis" /usr/share/X11/xkb/symbols/
sudo mkdir -p /etc/X11/xorg.conf.d
sudo cp "$BOOTSTRAP_BASEDIR/files/10-keyboard.conf" /etc/X11/xorg.conf.d/
sudo cp "$BOOTSTRAP_BASEDIR/files/10-mouse.conf" /etc/X11/xorg.conf.d/
sudo cp -r "$BOOTSTRAP_BASEDIR/consolas" /usr/local/share/fonts/
sudo fc-cache

sudo mkdir -p /etc/lightdm/lightdm.conf.d/
sudo cp "$BOOTSTRAP_BASEDIR/files/01-lightdm-autologin.conf" /etc/lightdm/lightdm.conf.d/

# dunst systemd user service doesn't load properly, I will run it manually in .xsessionrc.
# See my org notes for more info.
sudo systemctl --global disable dunst.service

~/dotfiles/bootstrap/software/install-zutty.sh
~/dotfiles/bootstrap/software/install-i3blocks.sh
