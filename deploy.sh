#!/bin/sh

SCRIPTDIR="$( cd "$(dirname "$0")" || exit >/dev/null 2>&1 ; pwd -P )"
SOURCEDIR="$SCRIPTDIR/.deploy"
TARGETDIR="$HOME"

# Different branches of this repo use different vim plugin mechanisms.
# Those different mechanisms expect plugins in different directories.
# Ensure that after deployment we have only those directories that we need.
rm -rf "$TARGETDIR/.vim"

cp -rL "$SOURCEDIR/." "$TARGETDIR"

if [ -d "$TARGETDIR/.ssh" ]; then
    chmod 700 "$TARGETDIR/.ssh"
fi
if [ -f "$TARGETDIR/.ssh/config" ]; then
    chmod 600 "$TARGETDIR/.ssh/config"
fi

if [ -d "$TARGETDIR/.config/i3/config.d" ]; then
    i3dir="$TARGETDIR/.config/i3"
    cp "$i3dir/config.d/config" "$i3dir/config"

    if test -n "$(find "$i3dir/config.d" -maxdepth 1 -name 'config-*' -print -quit)"
    # https://stackoverflow.com/a/4264351/9124671
    then
        cat "$i3dir"/config.d/config-* >> "$i3dir/config"
    fi

fi
