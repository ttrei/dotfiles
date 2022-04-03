#!/usr/bin/env bash

BGREEN='\033[1;92m'
NC='\033[0m' # No Color

DOTFILES="$( cd "$(dirname "$0")" || exit >/dev/null 2>&1 ; pwd -P )"
STAGINGDIR="$DOTFILES/.staging"
TARGETDIR=${TARGETDIR:-"$HOME"}

"$DOTFILES/stage.sh"

find "$STAGINGDIR" -type f -print0 | while IFS= read -r -d '' dotfile; do
    src=$(readlink -f "$dotfile")
    target="$TARGETDIR/${dotfile#"$STAGINGDIR/"}"
    diff_cmd="diff -x __pycache__ -r $src $target"
    diff_output="$($diff_cmd 2>&1)"
    if [ -n "$diff_output" ]; then
        echo -e "${BGREEN}$ $diff_cmd${NC}"
        echo -e "$diff_output"
    fi
done
