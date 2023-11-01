#!/usr/bin/env bash

ENVFILE=${DOTFILES_ENVFILE:-"$HOME/.dotfiles-env"}
if ! [ -f "$ENVFILE" ]; then
    echo "ABORT! dotfiles env file $ENVFILE not found."
    exit 1
fi
# shellcheck source=/dev/null
. "$ENVFILE"

if [ "$CONTEXT" = "work" ]; then
    if [ "$MACHINE" = "home-desktop" ]; then
        command="home-manager switch --flake $HOME/dotfiles#reinis@work-ubuntu"
    elif [ "$MACHINE" = "work-laptop" ] && [ "$EXECUTION_ENV" = "wsl" ]; then
        command="home-manager switch --flake $HOME/dotfiles#reinis@work-debian-wsl"
    fi
else
    if [ "$DISTRO" = "nixos" ]; then
        command="home-manager switch --flake $HOME/dotfiles#reinis@nixos"
    else
        command="home-manager switch --flake $HOME/dotfiles#reinis@non-nixos"
    fi
fi

echo "$command"
$command
