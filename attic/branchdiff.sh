#!/usr/bin/env bash

RED='\033[0;31m'
BRED='\033[0;91m'
GREEN='\033[0;32m'
BGREEN='\033[1;92m'
BBLUE='\033[1;34m'
NC='\033[0m' # No Color

if [ -n "$1" ]; then
    PATHSPEC="$@"
else
    PATHSPEC=". :!.deploy"
fi

function show_diff() {
    [ -z "$1" ] && return
    [ -z "$2" ] && return
    local branch=$1
    IFS=','; read -r -a deps <<< "$2"; unset IFS;

    for dep in "${deps[@]}"
    do
        command="git diff --stat --color $dep $branch -- $PATHSPEC"
        color_command="git diff --stat ${BBLUE}$dep${NC} ${BRED}$branch${NC} -- $PATHSPEC"
        diff_output="$($command 2>&1)"
        if [ -n "$diff_output" ]; then
            echo -e "$color_command"
            $command | grep -v "files changed" | grep -v "file changed"
        fi
    done
}

while read -r line; do
    [ -z "$line" ] && continue # skip empty lines
    [[ "$line" == \#* ]] && continue # skip comment lines
    branch=$(echo "$line" | cut -d ':' -f1)
    depstr=$(echo "$line" | cut -d ':' -f2)
    show_diff "$branch" "$depstr"
done <branch-dependencies.txt
