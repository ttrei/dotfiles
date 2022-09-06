#!/usr/bin/env bash

# To be used on non-NixOS distributions

if [ -x "$(command -v nix)" ]; then
    echo "Nix already installed"
    exit 1
fi

# https://nixos.org/download.html#download-nix
sh <(curl -L https://nixos.org/nix/install) --daemon
