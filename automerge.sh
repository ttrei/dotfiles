#/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BRED='\033[1;91m'
BGREEN='\033[1;92m'
NC='\033[0m' # No Color

function update_branch() {
    [ -z "$1" ] && echo "update_branch() called with empty argument" && return
    local branch="$1"
    local remote_branch="origin/$1"
    git checkout -q $branch
    if ! $(git merge-base --is-ancestor $remote_branch $branch); then
        echo "${GREEN}Pulling remote changes into '$branch' using 'git pull --rebase'${NC}"
        git pull --rebase || exit 1
    fi
}

function merge_dependencies() {
    [ -z "$1" ] && return
    [ -z "$2" ] && return
    local branch=$1
    IFS=','; local deps=($2); unset IFS;

    echo -e "${BGREEN}'$branch' depends on '$deps'${NC}"

    update_branch $branch

    for dep in "${deps[@]}"
    do
        update_branch $dep
        if ! $(git merge-base --is-ancestor $dep $branch); then
            echo -e "${GREEN}  merging '$dep' into '$branch'${NC}"
            git checkout -q $branch
            git merge --no-edit --rerere-autoupdate $dep
            if [ $? -ne 0 ]; then
                if local output=$(git rerere remaining) && [ -z "$output" ]; then
                    git commit --no-edit
                else
                    exit 1
                fi
            fi
        fi
    done
}

if output=$(git status --porcelain) && [ -n "$output" ]; then
    echo -e "${RED}Working directory is not clean. Abort.${NC}"
    exit 1
fi
current_branch=$(git rev-parse --abbrev-ref HEAD)

while read line; do
    [ -z "$line" ] && continue # skip empty lines
    [[ "$line" == \#* ]] && continue # skip comment lines
    branch=$(echo $line | cut -d ':' -f1)
    depstr=$(echo $line | cut -d ':' -f2)
    merge_dependencies $branch $depstr
done <branch-dependencies.txt

echo -e "${GREEN}Returning to '$current_branch'${NC}"
git checkout -q $current_branch
