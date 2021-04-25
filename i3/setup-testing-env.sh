#!/usr/bin/env bash

SETUP_TIMESTAMP_FILE=/tmp/doubleblind-testcase-timestamp.txt
TEARDOWN_TIME=2 # seconds

# https://freesound.org/people/florianreichelt/sounds/459992/
beep3="$HOME/Downloads/beep3.wav"

setup_finish_target_time=$(cat $SETUP_TIMESTAMP_FILE)
currenttime=$(date +%s%3N)
timediff=$(echo "$setup_finish_target_time - $currenttime" | bc) # milliseconds
if [[ "$timediff" -gt 0 ]]; then
    sleeptime=$(echo "scale=3; $timediff/1000" | bc -l) # seconds
    sleep "$sleeptime"
fi

windowid=$(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}')
winid="$(printf "%u\n" "$windowid" 2>/dev/null)"
i3-msg -q [id="$winid"] "focus; fullscreen"

aplay -q "$beep3" &

read -rp "Turn display off and press ENTER to end test" </dev/tty

teardown_finish_target_time=$(echo "$(date +%s%3N) + $TEARDOWN_TIME*1000" | bc) # milliseconds since epoch
echo "$teardown_finish_target_time" > "$SETUP_TIMESTAMP_FILE"

i3-msg exit
