#!/usr/bin/env bash

pushd ~/dotfiles/nix/nixos-config
sudo nixos-rebuild switch -I nixos-config=./system/configuration.nix
popd

