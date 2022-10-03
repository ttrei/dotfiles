#!/usr/bin/env sh

sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
sudo nix-channel --update

nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
