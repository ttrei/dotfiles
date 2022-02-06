#!/usr/bin/env sh

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
cd "$SCRIPT_DIR" || exit 1

./workspace-home-browser.py
./workspace-home-notes.py

