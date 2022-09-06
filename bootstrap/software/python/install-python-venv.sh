#!/usr/bin/env sh

set -o errexit

if [ -d ~/.venv ]; then
    echo "Cannot create global virtualenv - directory ~/.venv already exists"
    exit 1
fi

python3 -m venv --upgrade-deps ~/.venv
. ~/.venv/bin/activate
python -m pip install pipx
