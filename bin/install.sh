#!/usr/bin/env bash

set -o errexit

uv tool install --reinstall ~/dotfiles/i3/i3init
uv tool install --upgrade yt-dlp
uv tool install --upgrade llm
uv tool install --upgrade files-to-prompt

# https://llm.datasette.io/en/stable/plugins/directory.html
llm install --force-reinstall llm-cmd llm-deepseek llm-claude-3
