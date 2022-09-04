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
exuberant-ctags \
fd-find \
firmware-linux-nonfree \
firmware-realtek \
fzf \
git \
htop \
lua5.3 \
neovim \
pass \
python2 \
python3-i3ipc \
python3-pip \
python3-venv \
ripgrep \
samba \
shellcheck \
sudo \
sysstat \
tmux \
v4l2loopback-dkms \
vim \
#libclang-dev \

# TODO: move these to another script
sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
default-jdk-headless \
dmenu \
dunst \
feh \
firefox-esr \
gitk \
i3-wm \
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
#xbindkeys \
#qtcreator \
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
