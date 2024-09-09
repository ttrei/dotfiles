#!/usr/bin/env bash

set -o errexit
set -o nounset

pass os-secrets/nix-github-token > "$HOME"/.nix-github-token
pass os-secrets/anthropic-api-key > "$HOME"/.anthropic-api-key
