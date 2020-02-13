#!/bin/sh

SCRIPTDIR="$( cd "$(dirname "$0")" || exit >/dev/null 2>&1 ; pwd -P )"
SOURCEDIR="$SCRIPTDIR/.deploy"
TARGETDIR="$HOME"

cp -rL "$SOURCEDIR/." "$TARGETDIR"
