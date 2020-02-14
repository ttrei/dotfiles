#!/bin/sh

SCRIPTDIR="$( cd "$(dirname "$0")" || exit >/dev/null 2>&1 ; pwd -P )"
SOURCEDIR="$SCRIPTDIR/.deploy"
TARGETDIR="$HOME"

cp -rL "$SOURCEDIR/." "$TARGETDIR"

if [ -d "$TARGETDIR/.ssh" ]; then
    chmod 700 "$TARGETDIR/.ssh"
fi
if [ -f "$TARGETDIR/.ssh/config" ]; then
    chmod 600 "$TARGETDIR/.ssh/config"
fi
