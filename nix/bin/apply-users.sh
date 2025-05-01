#!/usr/bin/env bash

ENVFILE=${DOTFILES_ENVFILE:-"$HOME/.dotfiles-env"}
if ! [ -f "$ENVFILE" ]; then
    echo "ABORT! dotfiles env file $ENVFILE not found."
    exit 1
fi
# shellcheck source=/dev/null
. "$ENVFILE"

if [ "$CONTEXT" = "work" ]; then
    if [ "$MACHINE" = "jupiter" ]; then
        command="home-manager switch --flake $HOME/dotfiles#reinis@jupiter-work"
    elif [ "$MACHINE" = "mercury" ]; then
        command="home-manager switch --flake $HOME/dotfiles#reinis@mercury"
    fi
else
    if [ "$DISTRO" = "nixos" ]; then
        command="home-manager switch --flake $HOME/dotfiles#reinis@nixos"
    else
        command="home-manager switch --flake $HOME/dotfiles#reinis@non-nixos"
    fi
fi

echo "$command"
eval "$command"
