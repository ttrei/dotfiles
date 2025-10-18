#!/usr/bin/env sh

if [ -z "$1" ]; then
    echo "Usage: $0 <code directory>"
    exit 1
fi

IMAGE=gemini

sudo docker run --rm -it \
    -v "$HOME/.gemini:/home/node/.gemini" \
    -v "$HOME/.gemini-api-key:/home/node/.gemini/.env" \
    -v "$1":/home/node/code \
    $IMAGE \
    /bin/bash
