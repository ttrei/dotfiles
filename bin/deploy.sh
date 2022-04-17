#!/usr/bin/env bash

set -o errexit
set -o nounset

DOTFILES="$( cd "$(dirname "$0")/.." || exit >/dev/null 2>&1 ; pwd -P )"
STAGINGDIR=${STAGINGDIR:-"$DOTFILES/.staging"}
TARGETDIR=${TARGETDIR:-"$HOME"}

ARG=${1:-}

"$DOTFILES"/bin/stage.sh "$ARG"

echo "DEPLOYING $STAGINGDIR --> $TARGETDIR"

rm -rf "$TARGETDIR/.vim"
rm -rf "$TARGETDIR/bin/i3/workspace-scripts"

cp --recursive --dereference --remove-destination "$STAGINGDIR/." "$TARGETDIR"

if [ -d "$TARGETDIR/.ssh" ]; then
    chmod 700 "$TARGETDIR/.ssh"
fi
if [ -f "$TARGETDIR/.ssh/config" ]; then
    chmod 600 "$TARGETDIR/.ssh/config"
fi
