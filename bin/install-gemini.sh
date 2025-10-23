#!/usr/bin/env bash

set -o errexit
set -o nounset

DOTFILES="$( cd "$(dirname "$0")/.." || exit >/dev/null 2>&1 ; pwd -P )"

sudo docker build \
    -f "$DOTFILES/llm/Dockerfile-gemini" \
    --build-arg CACHEBUST=$(date +%s) \
    -t gemini ./llm
