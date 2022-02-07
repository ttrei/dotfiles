#!/usr/bin/env bash

pushd ~/dotfiles/nix/home-manager
home-manager switch -f ./reinis/home.nix
popd
