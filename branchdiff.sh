#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BGREEN='\033[1;92m'
NC='\033[0m' # No Color

[ -z "$1" ] && echo "Please specify the path that you want to diff" && exit 1
PATHSPEC="$1"

function show_diff() {
    [ -z "$1" ] && return
    [ -z "$2" ] && return
    local branch=$1
    IFS=','; read -r -a deps <<< "$2"; unset IFS;

    for dep in "${deps[@]}"
    do
        command="git diff --stat $dep..$branch -- $PATHSPEC"
        echo $command
        $command
    done
}

while read -r line; do
    [ -z "$line" ] && continue # skip empty lines
    [[ "$line" == \#* ]] && continue # skip comment lines
    branch=$(echo "$line" | cut -d ':' -f1)
    depstr=$(echo "$line" | cut -d ':' -f2)
    show_diff "$branch" "$depstr"
done <branch-dependencies.txt
