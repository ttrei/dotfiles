#!/usr/bin/env bash

if [ -x "$(command -v nix)" ]; then
    echo "Nix already installed"
    exit 1
fi

# https://nixos.org/download.html#download-nix
# Single-user installation because for multi-user install the installer warns
# about missing systemd.
sh <(curl -L https://nixos.org/nix/install) --no-daemon
