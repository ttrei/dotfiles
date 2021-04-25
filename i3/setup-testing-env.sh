#!/usr/bin/env bash

wm=$1

SETUP_TIMESTAMP_FILE=/tmp/doubleblind-testcase-timestamp.txt
TEARDOWN_TIME=2 # seconds

# https://freesound.org/people/florianreichelt/sounds/459992/
beep3="$HOME/Downloads/beep3.wav"

if [ "$wm" == "sway" ]; then
    # center the cursor
    #
    # I built ydotool manually because the version available in Debian didn't
    # support absolute positioning
    # https://github.com/ReimuNotMoe/ydotool
    #
    # make sure that ydotoold is running
    #
    # not sure why but it moves the cursor to (2x, 2y) coordinates instead of (x, y)
    ydotool mousemove --absolute 480 270 >/dev/null 2>&1
fi

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
