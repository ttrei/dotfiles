#!/usr/bin/env bash

ENVFILE=${DOTFILES_ENVFILE:-"$HOME/.dotfiles-env"}
if ! [ -f "$ENVFILE" ]; then
    echo "ABORT! dotfiles env file $ENVFILE not found."
    exit 1
fi
# shellcheck source=/dev/null
. "$ENVFILE"

if [ "$DISTRO" = "nixos" ]; then
    home-manager switch --flake "$HOME/.config/flakes#reinis@nixos"
else
    home-manager switch --flake "$HOME/.config/flakes#reinis@non-nixos"
fi
