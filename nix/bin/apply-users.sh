#!/usr/bin/env bash

pushd ~/dotfiles/nix/home-manager

home-manager switch -f ./reinis/home.nix

echo "Installing xow"
./reinis/overlays/pkgs/myxow/install-xow.sh

popd
