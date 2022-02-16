#!/usr/bin/env bash

pushd ~/dotfiles/nix/home-manager

home-manager switch -f ./reinis/home.nix

if [ "$HOSTNAME" = "kodi-new" ]; then
    echo "Installing xow"
    ./reinis/overlays/pkgs/myxow/install-xow.sh
fi

popd
