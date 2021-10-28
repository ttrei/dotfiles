#!/bin/sh

pushd ~/config
home-manager switch -f ./users/reinis/home.nix
popd
