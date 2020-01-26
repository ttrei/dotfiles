#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

[ -z "$EDITOR" ] && echo "EDITOR not set" && exit 1

current_branch=$(git rev-parse --abbrev-ref HEAD)
if output=$(git status --porcelain) && [ -n "$output" ]; then
    echo -e "${RED}Working directory is not clean. Abort.${NC}"
    exit 1
fi

tmpfile=$(mktemp)
echo "# Delete lines with branches that you want to keep as-is" >> $tmpfile
echo "# If unmodified, will reset *all* branches" >> $tmpfile
git for-each-ref --format='%(refname:short)' refs/heads/ >> $tmpfile
$EDITOR $tmpfile

while read line; do
    [ -z "$line" ] && continue # skip empty lines
    [[ "$line" == \#* ]] && continue # skip comment lines
    branch=$line
    git checkout --quiet $branch
    echo -e "${GREEN}resetting '$branch' to 'origin/$branch'${NC}"
    git reset --quiet --hard origin/$branch
done <$tmpfile
rm $tmpfile

git checkout --quiet $current_branch
