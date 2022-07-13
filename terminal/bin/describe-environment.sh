#!/usr/bin/env bash

if ! [ -x "$(command -v starship)" ]; then
    echo "starship not found"
    exit 1
fi

export STARSHIP_CONFIG=~/dotfiles/terminal/starship2.toml

print_if() {
    if [ -n "$1" ]; then
        echo "$1"
    fi
}

echo "pwd: $(pwd)"

# status module doesn't work.
# Apparently it doesn't receive the previous exit code.
# Moving it to the beginning of the script doesn't help either.
# st_status=$(starship module status)
# echo "$st_status"

st_git_branch=$(starship module git_branch)
st_git_commit=$(starship module git_commit)
st_git_status=$(starship module git_status)
print_if "$st_git_branch$st_git_commit$st_git_status"

st_python=$(starship module python)
print_if "$st_python"

st_java=$(starship module java)
print_if "$st_java"
