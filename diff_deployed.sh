#!/usr/bin/env bash

find .deploy -type l -print0 | while IFS= read -r -d '' link; do
    dotfile=$(readlink -f $link)
    target="$HOME/${link#.deploy/}"
    echo "diff $dotfile $target"
    diff $dotfile $target
done
