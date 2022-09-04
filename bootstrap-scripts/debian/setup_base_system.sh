#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

sudo cp files/sources.list-testing /etc/apt/sources.list
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
alsa-utils \
bash-completion \
diffstat \
dmenu \
dunst \
feh \
firefox-esr \
firmware-linux-nonfree \
firmware-realtek \
fzf \
fd-find \
git \
gitk \
htop \
i3-wm \
lightdm \
lua5.3 \
neovim \
pass \
pavucontrol \
pulseaudio \
python2 \
python3-pip \
python3-venv \
python3-i3ipc \
redshift \
ripgrep \
rofi \
shellcheck \
sudo \
tmux \
exuberant-ctags \
vim \
xdotool \
xfce4-terminal \
xinit \
xsel \
virt-viewer \
samba \
sysstat \
qemu-system-x86 \
default-jdk-headless \
obs-studio \
v4l2loopback-dkms \
#xbindkeys \
#qtcreator \
#libclang-dev \
#default-jre \

sudo DEBIAN_FRONTEND=noninteractive apt-get remove -q -y \
pipewire \

sudo cp files/lv-reinis /usr/share/X11/xkb/symbols/
sudo mkdir -p /etc/X11/xorg.conf.d
sudo cp files/10-keyboard.conf /etc/X11/xorg.conf.d/
sudo cp files/10-mouse.conf /etc/X11/xorg.conf.d/
sudo cp -r ./consolas /usr/local/share/fonts/
sudo fc-cache

sudo touch /etc/modprobe.d/blacklist.conf
echo "blacklist pcspkr" | sudo tee -a /etc/modprobe.d/blacklist.conf > /dev/null
sudo depmod -a
sudo update-initramfs -u

sudo mkdir -p /etc/lightdm/lightdm.conf.d/
sudo cp files/01-lightdm-autologin.conf /etc/lightdm/lightdm.conf.d/

# dunst systemd user service doesn't load properly, I will run it manually in .xsessionrc.
# See notes for more info.
sudo systemctl --global disable dunst.service

# TODO: My custom sudo configuration does not allow to set the DEBIAN_FRONTEND variable.
#       Maybe use the default config that allows to do anything.
# sudo cp files/sudoers /etc/sudoers
# sudo cp files/sudoers-admins /etc/sudoers.d/
# TODO: How can we add the user to sudo group if we don't have sudo rights yet?
# sudo usermod -a -G sudo reinis
