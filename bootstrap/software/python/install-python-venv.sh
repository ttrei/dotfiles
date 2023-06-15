#!/usr/bin/env sh

set -o errexit

if [ -d ~/.virtualenvs/misc ]; then
    echo "Cannot create global virtualenv - directory ~/.virtualenvs/misc already exists"
    exit 1
fi

# Make sure we use the system python.
# Don't want to create a virtualenv against a python from another virtualenv -
# it may disappear.
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
cd "$SCRIPT_DIR"
direnv allow
eval "$(direnv export bash)" || exit 1

python3 -m venv --upgrade-deps ~/.virtualenvs/misc
