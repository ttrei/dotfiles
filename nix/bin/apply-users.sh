#!/bin/sh

pushd ~/dotfiles/nix/nixos-config
home-manager switch -f ./users/reinis/home.nix
popd
