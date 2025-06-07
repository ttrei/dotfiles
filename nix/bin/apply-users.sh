#!/usr/bin/env bash

command="home-manager switch --flake $HOME/dotfiles#reinis@$(hostname)"

echo "$command"
eval "$command"
