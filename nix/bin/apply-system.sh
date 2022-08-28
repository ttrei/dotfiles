#!/usr/bin/env bash

pushd ~/.config/nixos
sudo nixos-rebuild switch -I nixos-config=./configuration.nix
popd
