#!/usr/bin/env sh

sudo -i nix-channel --update # nixpkgs channel is under root user
nix-channel --update
