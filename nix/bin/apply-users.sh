#!/usr/bin/env bash

pushd ~/.config/home-manager

home-manager switch -f ./config.nix

if [ "$HOSTNAME" = "kodi-new" ]; then
    echo "Installing xow"
    ./overlays/pkgs/myxow/install-xow.sh
fi

popd
