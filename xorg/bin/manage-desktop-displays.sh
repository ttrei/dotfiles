#!/usr/bin/env sh

[ -z "$1" ] && echo "Usage: $0 <one/two>" && exit 1

PRIMARY=$(xrandr_display_outputs.sh | grep VG245 | cut -d" " -f2)
SECONDARY=$(xrandr_display_outputs.sh | grep S23C650 | cut -d" " -f2)

if [ "$1" = "one" ]; then
    xrandr \
        --output "$PRIMARY" --auto --primary \
        --output "$SECONDARY" --off
elif [ "$1" = "two" ]; then
    xrandr \
        --output "$PRIMARY" --auto --primary \
        --output "$SECONDARY" --auto --right-of "$PRIMARY" --rotate left
fi
