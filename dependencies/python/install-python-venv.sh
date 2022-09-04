#!/usr/bin/env sh

set -o errexit

python3 -m venv --upgrade-deps ~/.venv
. ~/.venv/bin/activate
python -m pip install pipx
