#!/usr/bin/env sh

set -e

git clone ssh://reinis@mazais:/home/reinis/gitrepos/dotfiles.git
cd dotfiles
git checkout home-desktop-nixos-vbox
./deploy.sh

cd ~
git clone ssh://reinis@mazais:/home/reinis/gitrepos/dev.git
cd dev
git submodule update --init utilscripts
cd utilscripts
./deploy.sh

mkdir -p ~/bin
cd ~/bin
ln -s /run/current-system/sw/bin/nvim vim
