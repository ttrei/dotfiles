#!/usr/bin/env bash

set -o errexit

. ~/.venv/bin/activate

pipx install --force black
pipx install --force hatch
pipx install --force youtube-dl
pipx install --force yt-dlp
pipx install --force ipython

python -m pip install i3pyblocks[blocks.dbus,blocks.http,blocks.inotify,blocks.pulse]
# blocks.i3ipc
# blocks.ps
# blocks.x11

pushd ~/dotfiles
git submodule update --init i3/i3init/deps/i3ipc-python
popd

python -m pip install --editable ~/dotfiles/i3/i3init/deps/i3ipc-python
python -m pip install --editable ~/dotfiles/i3/i3init
