#!/usr/bin/env bash

sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old
sudo nix-collect-garbage -d
