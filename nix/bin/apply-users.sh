#!/usr/bin/env bash

command="sudo nixos-rebuild switch --flake $HOME/dotfiles#reinis@$(hostname)"

echo "$command"
eval "$command"
