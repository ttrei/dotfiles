#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

BGREEN='\033[1;92m'
NC='\033[0m' # No Color

DOTFILES="$( cd "$(dirname "$0")/.." || exit >/dev/null 2>&1 ; pwd -P )"
STAGINGDIR=${STAGINGDIR:-"$DOTFILES/.staging"}
TARGETDIR=${TARGETDIR:-"$HOME"}

ARG=${1:-}

"$DOTFILES"/bin/stage.sh "$ARG"

if [ "$ARG" == "-v" ]; then
    echo "DIFF $STAGINGDIR <--> $TARGETDIR"
    echo
fi

find "$STAGINGDIR" -type l,f -print0 | while IFS= read -r -d '' dotfile; do
    src=$(readlink -f "$dotfile")
    dst="$TARGETDIR/${dotfile#"$STAGINGDIR/"}"
    diff_cmd="diff -r $src $dst"
    diff_output="$($diff_cmd 2>&1 || true)"
    if [ -n "$diff_output" ]; then
        if [ "$ARG" == "-v" ]; then
            echo -e "${BGREEN}$ $diff_cmd${NC}"
            echo -e "$diff_output\n"
        else
            echo -e "$dst"
        fi
    fi
done
