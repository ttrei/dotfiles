#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ -z "$BOOTSTRAP_BASEDIR" ]]; then
    echo "BOOTSTRAP_BASEDIR not set" 1>&2
    exit 1
fi

~/dotfiles/bin/select-config.sh

sudo cp "$BOOTSTRAP_BASEDIR/files/sources.list-testing" /etc/apt/sources.list
sudo DEBIAN_FRONTEND=noninteractive apt-get update -q
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -q -y
sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -q -y

sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
alsa-utils \
bash-completion \
clang-format \
cmake \
curl \
diffstat \
direnv \
exuberant-ctags \
fd-find \
firmware-amd-graphics \
firmware-realtek \
fzf \
git \
htop \
jq \
lua5.3 \
moreutils \
neovim \
ninja-build \
pass \
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
#libboost-all-dev
#libclang-dev

sudo DEBIAN_FRONTEND=noninteractive apt-get remove -q -y \
pipewire \

sudo touch /etc/modprobe.d/blacklist.conf
echo "blacklist pcspkr" | sudo tee -a /etc/modprobe.d/blacklist.conf > /dev/null
sudo depmod -a
sudo update-initramfs -u

~/dotfiles/bin/deploy.sh

~/dotfiles/bootstrap/software/python/install-python-venv.sh || true
~/dotfiles/bootstrap/software/python/install-python-apps.sh

~/dotfiles/bootstrap/software/nix/install-nix.sh || true
. /etc/profile.d/nix.sh # Access nix without restarting shell
~/dotfiles/bootstrap/software/nix/install-home-manager.sh || true
~/dotfiles/nix/bin/update-user.sh
~/dotfiles/nix/bin/apply-users.sh

# TODO: My custom sudo configuration does not allow to set the DEBIAN_FRONTEND variable.
#       Maybe use the default config that allows to do anything.
# sudo cp "$BOOTSTRAP_BASEDIR/files/sudoers" /etc/sudoers
# sudo cp "$BOOTSTRAP_BASEDIR/files/sudoers-admins" /etc/sudoers.d/
# TODO: How can we add the user to sudo group if we don't have sudo rights yet?
# sudo usermod -a -G sudo reinis
