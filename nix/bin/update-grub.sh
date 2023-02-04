#!/usr/bin/env bash

pushd ~/.config/nixos
sudo nixos-rebuild --install-bootloader switch -I nixos-config=./configuration.nix
popd
