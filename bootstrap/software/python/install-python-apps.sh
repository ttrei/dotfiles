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

uv tool install --reinstall ~/dotfiles/i3/i3init
uv tool install --upgrade yt-dlp
uv tool install --upgrade llm

if ! [ -d /tmp/chimeracat ]; then
    git clone https://github.com/scottvr/chimeracat.git /tmp/chimeracat
else
    pushd /tmp/chimeracat
    git pull
    popd
fi
uv tool install --reinstall /tmp/chimeracat

# https://llm.datasette.io/en/stable/plugins/directory.html
llm install --force-reinstall llm-cmd llm-deepseek llm-claude-3
