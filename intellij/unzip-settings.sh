#!/usr/bin/env sh

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

app=$1
if [ -z "$app" ] || { [ "$app" != "idea" ] && [ "$app" != "pycharm" ]; }; then
    echo "Usage: $0 <idea|pycharm>"
    exit 1
fi

cd "$SCRIPT_DIR" || exit
if ! [ -f "settings.zip" ]; then
    echo "$SCRIPT_DIR/settings.zip missing"
    exit 1
fi

if ! [ -d "$app" ]; then
    echo "ERROR: $app is not a directory";
    exit 1;
fi
rm -rf "$app"
unzip settings.zip -d "$app"
