#!/usr/bin/env bash

command="sudo nixos-rebuild switch --flake $HOME/dotfiles#$(hostname)"

echo "$command"
eval "$command"
