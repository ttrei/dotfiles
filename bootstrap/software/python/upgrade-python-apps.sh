#!/usr/bin/env bash

set -o errexit

. ~/.venv/bin/activate
pipx upgrade-all

python -m pip install --upgrade i3pyblocks

pushd ~/dotfiles/i3/i3init/deps/i3ipc-python
git checkout master
git pull
popd
