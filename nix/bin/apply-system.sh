#!/usr/bin/env bash

command="sudo nixos-rebuild switch --flake $HOME/.config/flakes#$(hostname)"

echo "$command"
$command
