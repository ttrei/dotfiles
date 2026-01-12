#!/usr/bin/env bash

command="sudo nixos-rebuild switch --flake $HOME/dev/dotfiles#$(hostname)"

echo "$command"
eval "$command"
