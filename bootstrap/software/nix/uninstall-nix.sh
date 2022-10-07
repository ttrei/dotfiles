#!/usr/bin/env bash

# https://nixos.org/manual/nix/stable/installation/installing-binary.html#multi-user-installation

if ! [ -x "$(command -v nix)" ]; then
    echo "Nix not installed"
    exit 1
fi

sudo rm -rf /etc/profile/nix.sh /etc/nix /nix ~root/.nix-profile ~root/.nix-defexpr ~root/.nix-channels ~/.nix-profile ~/.nix-defexpr ~/.nix-channels

# If you are on Linux with systemd, you will need to run:
sudo systemctl stop nix-daemon.socket
sudo systemctl stop nix-daemon.service
sudo systemctl disable nix-daemon.socket
sudo systemctl disable nix-daemon.service
sudo systemctl daemon-reload
