#!/usr/bin/env bash

set -o errexit
set -o nounset

pass os-secrets/nix-github-token > "$HOME"/.nix-github-token
pass os-secrets/anthropic-api-key > "$HOME"/.anthropic-api-key
pass os-secrets/openrouter-api-key > "$HOME"/.openrouter-api-key
pass os-secrets/deepseek-api-key > "$HOME"/.deepseek-api-key
pass os-secrets/openexchangerates-app-id > "$HOME"/.openexchangerates-app-id

mkdir -p "$HOME"/.config/io.datasette.llm
pass other/llm-keys.json > "$HOME"/.config/io.datasette.llm/keys.json
