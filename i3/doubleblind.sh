#!/usr/bin/env bash

N=3
SETUP_TIME=5 # seconds

beep1="$HOME/Downloads/beep1.wav"
beep2="$HOME/Downloads/beep2.wav"
beep3="$HOME/Downloads/beep3.wav"

SEQUENCE_FILE=/var/tmp/doubleblind-sequence.txt

rm -f "$SEQUENCE_FILE.tmp"
for i in $(seq 1 $N)
do
    echo "i3" >> "$SEQUENCE_FILE.tmp"
    echo "sway" >> "$SEQUENCE_FILE.tmp"
done

# prompt to shut off display and press ENTER
# record current time and wm, write to tmp file
# start wm
# execute startup script, read recorded time and wm from tmp file
#   start zutty
#   maximize zutty
#   wait until SETUP_TIME elapsed
#   beep to signal that setup has finished

cat "$SEQUENCE_FILE.tmp" | shuf > "$SEQUENCE_FILE"

setup_start_time=$(date +%s%3N) # milliseconds since epoch
wm="i3"

aplay -q "$beep1"
