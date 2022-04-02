#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BGREEN='\033[1;92m'
NC='\033[0m' # No Color

function update_branch() {
    [ -z "$1" ] && echo "update_branch() called with empty argument" && return
    local branch="$1"
    local remote_branch="origin/$1"
    git checkout -q "$branch"
    if git merge-base --is-ancestor "$remote_branch" "$branch"; then
        # `remote_branch` already merged
        return
    fi
    echo -e "${GREEN}Pulling remote changes into '$branch' using 'git rebase'${NC}"
    git rebase || exit 1
}

function merge_dependencies() {
    [ -z "$1" ] && return
    [ -z "$2" ] && return
    local branch=$1
    IFS=','; read -r -a deps <<< "$2"; unset IFS;

    echo -e "${BGREEN}'$branch' depends on '$2'${NC}"

    update_branch "$branch"

    for dep in "${deps[@]}"
    do
        update_branch "$dep"
        if git merge-base --is-ancestor "$dep" "$branch"; then
            # `dep` branch already merged
            continue
        fi
        echo -e "${GREEN}  merging '$dep' into '$branch'${NC}"
        git checkout -q "$branch"
        if ! git merge --no-edit --rerere-autoupdate "$dep"; then
            local remaining
            remaining=$(git rerere remaining)
            if [ -z "$remaining" ]; then
                git commit --no-edit
            else
                exit 1
            fi
        fi
    done
}

gitstatus=$(git status --porcelain)
if [ -n "$gitstatus" ]; then
    echo -e "${RED}Working directory is not clean. Abort.${NC}"
    exit 1
fi
current_branch=$(git rev-parse --abbrev-ref HEAD)

echo -e "${GREEN}Fetching remote changes${NC}"
git fetch --all

while read -r line; do
    [ -z "$line" ] && continue # skip empty lines
    [[ "$line" == \#* ]] && continue # skip comment lines
    branch=$(echo "$line" | cut -d ':' -f1)
    depstr=$(echo "$line" | cut -d ':' -f2)
    merge_dependencies "$branch" "$depstr"
done <branch-dependencies.txt

echo -e "${GREEN}Returning to '$current_branch'${NC}"
git checkout -q "$current_branch"
