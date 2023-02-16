#!/usr/bin/env bash

ENVFILE=${DOTFILES_ENVFILE:-"$HOME/.dotfiles-env"}
if ! [ -f "$ENVFILE" ]; then
    echo "ABORT! dotfiles env file $ENVFILE not found."
    exit 1
fi
# shellcheck source=/dev/null
. "$ENVFILE"

pushd ~/.config/home-manager/reinis || exit

if [ "$DISTRO" = "nixos" ]; then
    home-manager switch -f ./nixos.nix
else
    home-manager switch -f ./non-nixos.nix
fi

popd || exit
