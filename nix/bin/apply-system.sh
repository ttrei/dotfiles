#!/usr/bin/env bash

sudo nixos-rebuild switch --flake "$HOME/.config/flakes#$(hostname)"
