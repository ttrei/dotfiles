#!/usr/bin/env sh

set -o errexit

. ~/.venv/bin/activate
pipx install --force black
pipx install --force hatch
pipx install --force youtube-dl
pipx install --force yt-dlp
pipx install --force ipython
