#!/usr/bin/env sh

set -o errexit

. ~/.venv/bin/activate
pipx install --force black
pipx install --force youtube-dl
