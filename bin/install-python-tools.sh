#!/usr/bin/env bash

set -o errexit
set -o nounset

DOTFILES="$( cd "$(dirname "$0")/.." || exit >/dev/null 2>&1 ; pwd -P )"

uv tool install --reinstall ~/dotfiles/i3/i3init
uv tool install --upgrade yt-dlp
uv tool install --upgrade llm
uv tool install --upgrade files-to-prompt

# https://llm.datasette.io/en/stable/plugins/directory.html
# llm install --force-reinstall llm-cmd llm-deepseek llm-claude-3
