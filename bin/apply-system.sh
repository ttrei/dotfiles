#!/usr/bin/env bash

DOTFILES="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"

command="sudo nixos-rebuild switch --flake $DOTFILES#$(hostname)"

echo "$command"
eval "$command"
