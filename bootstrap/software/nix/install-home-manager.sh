#!/usr/bin/env bash

set -o errexit

if [ -x "$(command -v home-manager)" ]; then
    echo "home-manager already installed"
    exit 1
fi

mkdir -p ~/.local/state/nix/profiles
nix run home-manager/master -- init --switch
rm -rf ~/.config/home-manager
