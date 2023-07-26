#!/usr/bin/env bash

set -o errexit

echo "This script is obsolete. See README.md for how to install flake-based home-manager."
exit 1

if [ -x "$(command -v home-manager)" ]; then
    echo "home-manager already installed"
    exit 1
fi

# https://nix-community.github.io/home-manager/index.html#sec-install-standalone
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}
nix-shell '<home-manager>' -A install
