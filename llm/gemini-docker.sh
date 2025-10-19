#!/usr/bin/env sh

if [ -z "$1" ]; then
    code_dir="$HOME/dev"
else
    code_dir=$1
fi

IMAGE=gemini

sudo docker run --rm -it \
    -v "$HOME/.gemini:/home/node/.gemini" \
    -v "$HOME/.gemini-api-key:/home/node/.gemini/.env" \
    -v "$code_dir":/home/node/dev \
    $IMAGE \
    /bin/bash
