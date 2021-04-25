#!/usr/bin/env bash

N=1

# https://freesound.org/people/thisusernameis/sounds/426888/
beep1="$HOME/Downloads/beep1.wav"
# https://freesound.org/people/Eponn/sounds/528867/
beep2="$HOME/Downloads/beep2.wav"
# https://freesound.org/people/florianreichelt/sounds/459992/
beep3="$HOME/Downloads/beep3.wav"

SEQUENCE_FILE=/var/tmp/doubleblind-sequence.txt
SETUP_TIMESTAMP_FILE=/tmp/doubleblind-testcase-setup-starttime.txt

rm -f "$SEQUENCE_FILE.tmp"
for i in $(seq 1 $N)
do
    echo "i3" >> "$SEQUENCE_FILE.tmp"
    echo "sway" >> "$SEQUENCE_FILE.tmp"
done

cat "$SEQUENCE_FILE.tmp" | shuf > "$SEQUENCE_FILE"

setup_start_time=$(date +%s%3N) # milliseconds since epoch
echo "$setup_start_time" > "$SETUP_TIMESTAMP_FILE"

while read -r line; do
    aplay -q "$beep1" &
    echo "Executing $line at $(date +%FT%H-%M-%S)"
    if [ "i3" == "$line" ]; then
        startx -- vt1 2>/dev/null
    elif [ "sway" == "$line" ]; then
        sway 1>/dev/null 2>&1
    fi
    echo "Returned from $line at $(date +%FT%H-%M-%S)"
    aplay -q "$beep2" &
    sleep 1
done <"$SEQUENCE_FILE"

# prompt to shut off display and press ENTER
# record current time and wm, write to tmp file
# start wm
# execute startup script, read recorded time and wm from tmp file
#   start zutty
#   maximize zutty
#   wait until SETUP_TIME elapsed
#   beep to signal that setup has finished

