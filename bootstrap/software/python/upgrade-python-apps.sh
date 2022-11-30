#!/usr/bin/env bash

set -o errexit

. ~/.venv/bin/activate
pipx upgrade-all

pushd ~/dotfiles/i3/i3init/deps/i3ipc-python
git checkout master
git pull
popd
