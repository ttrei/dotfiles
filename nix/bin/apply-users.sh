#!/usr/bin/env bash

pushd ~/dotfiles/nix/home-manager/reinis

home-manager switch -f ./non-nixos.nix

popd
