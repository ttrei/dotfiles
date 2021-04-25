#!/usr/bin/env bash

SETUP_TIME=2 # seconds
SETUP_TIMESTAMP_FILE=/tmp/doubleblind-testcase-setup-starttime.txt

starttime=$(cat $SETUP_TIMESTAMP_FILE)
targettime=$(echo "$starttime + $SETUP_TIME*1000" | bc)
currenttime=$(date +%s%3N)
timediff=$(echo "$targettime - $currenttime" | bc) # milliseconds
if [[ "$timediff" -gt 0 ]]; then
    sleeptime=$(echo "scale=3; $timediff/1000" | bc -l) # seconds
    sleep "$sleeptime"
fi

windowid=$(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}')
winid="$(printf "%u\n" "$windowid" 2>/dev/null)"
i3-msg -q [id="$winid"] "focus; fullscreen"

# https://freesound.org/people/florianreichelt/sounds/459992/
aplay -q "$HOME/Downloads/beep3.wav" &

bash
