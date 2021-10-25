#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if ! [ -x "$(command -v fzf)" ]; then
    echo "Error: fzf is not installed" >&2
    exit 1
fi

local_branches=$(git for-each-ref --format='%(refname:lstrip=2)' refs/heads/)
remote_branches=$(git for-each-ref --format='%(refname:lstrip=3)' refs/remotes/)
if [[ $# -lt 1 ]]; then
    branches="$local_branches\n$remote_branches"
elif [ "$1" = "--local" ]; then
    branches="$local_branches"
elif [ "$1" = "--remote" ]; then
    branches="$remote_branches"
fi
branch=$(echo -e "$branches" | grep -v HEAD | sort | uniq | fzf --layout=reverse)

if [ -z "$branch" ]; then
    echo "No branch selected" >&2
    exit 1
fi

if git show-ref --verify --quiet "refs/heads/$branch"; then
    # Already exists locally
    command="git checkout $branch"
    echo "$command"
    $command
    exit 0
fi

# Create new local branch and select remote branch to track if there are many
remote_branches=$(git for-each-ref --format='%(refname:lstrip=2)' "refs/remotes/*/$branch")
count=$(echo -e "$remote_branches" | wc -l)
if [ "$count" -eq "1" ]; then
    remote_branch="$remote_branches"
else
    prompt="Select remote branch to track:"
    remote_branch=$(echo -e "$remote_branches" | fzf --layout=reverse --prompt="$prompt")
fi

command="git checkout -b $branch --track $remote_branch"
echo "$command"
$command
