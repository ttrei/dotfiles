#!/usr/bin/env bash

BGREEN='\033[1;92m'
NC='\033[0m' # No Color

SCRIPTDIR="$( cd "$(dirname "$0")" || exit >/dev/null 2>&1 ; pwd -P )"
SOURCEDIR=${SOURCEDIR:-"$SCRIPTDIR/.deploy"}
TARGETDIR=${TARGETDIR:-"$HOME"}

find "$SOURCEDIR" -type l -print0 | while IFS= read -r -d '' link; do
    src=$(readlink -f "$link")
    target="$TARGETDIR/${link#$SOURCEDIR/}"
    diff_cmd="diff -x __pycache__ -r $src $target"
    diff_output="$($diff_cmd 2>&1)"
    if [ -n "$diff_output" ]; then
        echo -e "${BGREEN}$ $diff_cmd${NC}"
        echo -e "$diff_output"
    fi
done
