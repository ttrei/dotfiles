#!/usr/bin/env bash

set -o errexit

# Make sure we use the system python.
# Don't want to create a virtualenv against a python from another virtualenv -
# it may disappear.
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
cd "$SCRIPT_DIR"
direnv allow
eval "$(direnv export bash)" || exit 1

rm -rf ~/.virtualenvs/misc
uv venv ~/.virtualenvs/misc

# shellcheck disable=SC1090
. ~/.virtualenvs/misc/bin/activate
uv pip install -r "$SCRIPT_DIR/requirements.txt"
uv pip install --editable ~/dotfiles/i3/i3init

uv tool install llm
