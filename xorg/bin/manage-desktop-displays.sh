#!/usr/bin/env sh

[ -z "$1" ] && echo "Usage: $0 <one/two>" && exit 1

set -o nounset

if [ "$1" = "one" ]; then
    xrandr \
        --output "$PRIMARY_DISPLAY" --auto --primary \
        --output "$SECONDARY_DISPLAY" --off
elif [ "$1" = "two" ]; then
    xrandr \
        --output "$PRIMARY_DISPLAY" --auto --primary \
        --output "$SECONDARY_DISPLAY" --auto --right-of "$PRIMARY_DISPLAY" --rotate left
fi
