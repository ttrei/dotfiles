#!/usr/bin/env sh

SETUP_TIME=5 # seconds
SETUP_TIMESTAMP_FILE=/tmp/doubleblind-testcase-setup-starttime.txt

beep3="$HOME/Downloads/beep3.wav"

sleep 1
windowid=$(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}')
winid="$(printf "%u\n" $windowid 2>/dev/null)"
i3-msg -q [id=\"$winid\"] "focus; fullscreen"

aplay -q "$beep3" &
bash
