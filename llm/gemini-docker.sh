#!/usr/bin/env sh

if [ -z "$1" ]; then
    echo "Usage: $0 <code directory>"
    exit 1
fi

# Check latest tag here
# https://console.cloud.google.com/artifacts/docker/gemini-code-dev/us/gemini-cli/sandbox
IMAGE=us-docker.pkg.dev/gemini-code-dev/gemini-cli/sandbox:0.10.0-preview.1

sudo docker run --rm -it \
    -v "$HOME/.gemini:/home/node/.gemini" \
    -v "$HOME/.gemini-api-key:/home/node/.gemini/.env" \
    -v "$1":/home/node/code \
    $IMAGE \
    /bin/bash -c "cd /home/node/code && gemini"
