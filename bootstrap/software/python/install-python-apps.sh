#!/usr/bin/env bash

set -o errexit

# NOTE: maybe this is not needed when using uv
# # Make sure we use the system python.
# # Don't want to create a virtualenv against a python from another virtualenv -
# # it may disappear.
# SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
# cd "$SCRIPT_DIR"
# direnv allow
# eval "$(direnv export bash)" || exit 1

rm -rf ~/.virtualenvs/misc
uv venv ~/.virtualenvs/misc

uv tool install --upgrade ~/dotfiles/i3/i3init
uv tool install --upgrade yt-dlp
uv tool install --upgrade llm
# https://llm.datasette.io/en/stable/plugins/directory.html
llm install --upgrade llm-cmd
llm install --upgrade llm-deepseek
llm install --upgrade llm-claude-3

if ! [ -d /tmp/chimeracat ]; then
    git clone https://github.com/scottvr/chimeracat.git /tmp/chimeracat
fi
uv tool install --upgrade /tmp/chimeracat
