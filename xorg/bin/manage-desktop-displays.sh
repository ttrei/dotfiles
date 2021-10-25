#!/usr/bin/env sh

[ -z "$1" ] && echo "Usage: $0 <one/two>" && exit 1

PRIMARY="HDMI-2"
SECONDARY="HDMI-1"

if [ "$1" = "one" ]; then
    xrandr \
        --output $PRIMARY --auto --primary \
        --output $SECONDARY --off
elif [ "$1" = "two" ]; then
    xrandr \
        --output $PRIMARY --auto --primary \
        --output $SECONDARY --auto --right-of $PRIMARY
fi
