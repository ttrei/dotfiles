#!/usr/bin/env bash

find .deploy -type l -print0 | while IFS= read -r -d '' link; do
    dotfile=$(readlink -f "$link")
    target="$HOME/${link#.deploy/}"
    cmd="diff -r $dotfile $target"
    if [ -n "$($cmd)" ]; then
        echo -e "\n$ $cmd"
        $cmd
    fi
done
