#!/usr/bin/env bash

command="home-manager switch --flake $HOME/dev/dotfiles#reinis@$(hostname)"

echo "$command"
eval "$command"
