#!/usr/bin/env bash

# Extract JIRA issue from the current branch name (feature/IPS-34, bugfix/IPS-34, etc)

set -o errexit
set -o nounset
set -o pipefail

current_branch=$(git branch --show-current)
jira_issue=$(echo "$current_branch" \
    | cut -d "/" -f2 \
    | cut -d "-" -f1,2 \
    | cut -d "/" -f1 \
)
git commit -v -e -m "$jira_issue" "$@"
