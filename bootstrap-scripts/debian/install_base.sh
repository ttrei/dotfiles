#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

sudo cp files/sources.list-testing /etc/apt/sources.list
sudo DEBIAN_FRONTEND=noninteractive apt-get update -q
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -q -y
sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -q -y

sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
alsa-utils \
bash-completion \
curl \
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

sudo DEBIAN_FRONTEND=noninteractive apt-get remove -q -y \
pipewire \

sudo touch /etc/modprobe.d/blacklist.conf
echo "blacklist pcspkr" | sudo tee -a /etc/modprobe.d/blacklist.conf > /dev/null
sudo depmod -a
sudo update-initramfs -u

# TODO: My custom sudo configuration does not allow to set the DEBIAN_FRONTEND variable.
#       Maybe use the default config that allows to do anything.
# sudo cp files/sudoers /etc/sudoers
# sudo cp files/sudoers-admins /etc/sudoers.d/
# TODO: How can we add the user to sudo group if we don't have sudo rights yet?
# sudo usermod -a -G sudo reinis
