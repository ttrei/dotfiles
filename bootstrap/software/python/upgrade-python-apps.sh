#!/usr/bin/env sh

set -o errexit

. ~/.venv/bin/activate
pipx upgrade-all
