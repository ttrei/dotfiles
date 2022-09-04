#!/usr/bin/env sh

# Installs nix and home-manager.
# To be used on non-NixOS distributions.

# nix
# https://nixos.org/download.html#download-nix
sh <(curl -L https://nixos.org/nix/install) --daemon

# home-manager
# https://nix-community.github.io/home-manager/index.html#sec-install-standalone
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz
nix-channel --update
export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}
nix-shell '<home-manager>' -A install
