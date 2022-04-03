#!/bin/sh

DOTFILES="$( cd "$(dirname "$0")" || exit >/dev/null 2>&1 ; pwd -P )"
STAGINGDIR="$DOTFILES/.staging"
TARGETDIR=${TARGETDIR:-"$HOME"}

"$DOTFILES/stage.sh"

echo "DEPLOYING $STAGINGDIR --> $TARGETDIR"

rm -rf "$TARGETDIR/.vim"

rm -rf "$TARGETDIR/bin/i3/workspace-scripts"

cp --recursive \
    --remove-destination \
    "$STAGINGDIR/." "$TARGETDIR"
