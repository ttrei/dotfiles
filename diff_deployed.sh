#!/usr/bin/env bash

BGREEN='\033[1;92m'
NC='\033[0m' # No Color

SCRIPTDIR="$( cd "$(dirname "$0")" || exit >/dev/null 2>&1 ; pwd -P )"
LINKDIR="$SCRIPTDIR/.deploy"
TARGETDIR="$HOME"

find "$LINKDIR" -type l -print0 | while IFS= read -r -d '' link; do
    src=$(readlink -f "$link")
    target="$TARGETDIR/${link#$LINKDIR/}"
    diff_cmd="diff -r $src $target"
    diff_output="$($diff_cmd)"
    if [ -n "$diff_output" ]; then
        echo -e "${BGREEN}$ $diff_cmd${NC}"
        echo -e "$diff_output"
    fi
done
