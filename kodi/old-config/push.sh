#!/usr/bin/env bash

files=$(find ./kodi -type f -name *xml -printf '%P\n')

for f in $files; do
    cmd="cp ./kodi/$f $HOME/.kodi/$f"
    echo $cmd
    $cmd
done
