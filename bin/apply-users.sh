#!/usr/bin/env bash

DOTFILES="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"

command="home-manager switch --flake $DOTFILES#reinis@$(hostname)"

echo "$command"
eval "$command"
