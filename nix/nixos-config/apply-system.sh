#!/bin/sh

pushd ~/config
sudo nixos-rebuild switch -I nixos-config=./system/configuration.nix
popd

