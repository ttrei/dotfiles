#!/usr/bin/env bash

set -o errexit

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

. ~/.venv/bin/activate
python -m pip install -r "$SCRIPT_DIR/requirements.txt"
python -m pip install --editable ~/dotfiles/i3/i3init
