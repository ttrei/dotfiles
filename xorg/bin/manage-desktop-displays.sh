#!/usr/bin/env sh

[ -z "$1" ] && echo "Usage: $0 <one/two>" && exit 1

set -o nounset

# The output positions can be easily chosen with the arandr tool.
#
# I specify the framebuffer dimensions explicitly to avoid a bug where the display goes black for
# a moment when switching from two-display to one-display configuration.
# https://gitlab.freedesktop.org/xorg/xserver/-/issues/216

if [ "$1" = "one" ]; then
    xrandr --fb 3000x2220 \
        --output "$PRIMARY_DISPLAY" --auto --primary \
        --output "$SECONDARY_DISPLAY" --off
elif [ "$1" = "two" ]; then
    xrandr --fb 3000x2220 \
        --output "$PRIMARY_DISPLAY" --primary --mode 1920x1080 --pos 0x300 --rotate normal \
        --output "$SECONDARY_DISPLAY" --mode 1920x1080 --pos 1920x0 --rotate left
fi


