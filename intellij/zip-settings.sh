#!/usr/bin/env sh

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

app=$1
if [ -z "$app" ] || ([ "$app" != "idea" ] && [ "$app" != "pycharm" ]); then
    echo "Usage: $0 <idea|pycharm>"
    exit 1
fi

cd "$SCRIPT_DIR/$app" || exit
zip -r ../settings.zip *
