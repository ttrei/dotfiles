#!/usr/bin/env sh

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

[ -n "$1" ] && [ "$1" != "0" ] && echo "exit status: $1"

st_git_branch=$(starship module git_branch)
st_git_commit=$(starship module git_commit)
st_git_status=$(starship module git_status)
print_if "$st_git_branch$st_git_commit$st_git_status"

st_python=$(starship module python)
print_if "$st_python"

st_java=$(starship module java)
print_if "$st_java"

st_k8s=$(starship module kubernetes)
print_if "$st_k8s"
