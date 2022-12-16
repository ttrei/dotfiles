#!/usr/bin/env bash

# https://nixos.org/manual/nix/stable/installation/installing-binary.html#multi-user-installation

if ! [ -x "$(command -v nix)" ]; then
    echo "Nix not installed"
    exit 1
fi

sudo rm -rf /nix /etc/nix /etc/profile/nix.sh ~root/.nix-profile ~root/.nix-defexpr ~root/.nix-channels ~/.nix-profile ~/.nix-defexpr ~/.nix-channels

for i in $(seq 30001 30032); do
  sudo userdel $i
done
sudo groupdel 30000

# If you are on Linux with systemd, you will need to run:
sudo systemctl stop nix-daemon.socket
sudo systemctl stop nix-daemon.service
sudo systemctl disable nix-daemon.socket
sudo systemctl disable nix-daemon.service
sudo systemctl daemon-reload
