#!/usr/bin/env bash

N=8
SETUP_TIME=2 # seconds

# https://freesound.org/people/thisusernameis/sounds/426888/
beep1="$HOME/Downloads/beep1.wav"
# https://freesound.org/people/Eponn/sounds/528867/
# beep2="$HOME/Downloads/beep2.wav"
# https://freesound.org/people/florianreichelt/sounds/459992/
beep3="$HOME/Downloads/beep3.wav"


RESULTS_FILE=/var/tmp/doubleblind-results.txt
SEQUENCE_FILE=/var/tmp/doubleblind-sequence.txt
SETUP_TIMESTAMP_FILE=/tmp/doubleblind-testcase-timestamp.txt

# Generate the testing sequence
rm -f "$SEQUENCE_FILE.tmp"
# at least one of each type
echo "i3" >> "$SEQUENCE_FILE.tmp"
echo "sway" >> "$SEQUENCE_FILE.tmp"
# for a total of N+2 entries
for i in $(seq 1 $N)
do
    echo "$i" > /dev/null # Shut up shellcheck
    if [[ $((RANDOM % 2)) -eq 0 ]]; then
        echo "i3" >> "$SEQUENCE_FILE.tmp"
    else
        echo "sway" >> "$SEQUENCE_FILE.tmp"
    fi
done
shuf "$SEQUENCE_FILE.tmp" > "$SEQUENCE_FILE"

# Perform testing
rm -f "$RESULTS_FILE"
while read -r line; do
    read -rp "Turn display off, press ENTER, wait for beep, turn display on" </dev/tty

    setup_finish_target_time=$(echo "$(date +%s%3N) + $SETUP_TIME*1000" | bc) # milliseconds since epoch
    echo "$setup_finish_target_time" > "$SETUP_TIMESTAMP_FILE"

    echo "$line" >> "$RESULTS_FILE"

    # setup-testing-env.sh will be executed on startup
    # (configured in i3 and sway configs)
    if [ "i3" == "$line" ]; then
        startx -- vt1 2>/dev/null
    elif [ "sway" == "$line" ]; then
        sway 1>/dev/null 2>&1
    fi

    teardown_finish_target_time=$(cat $SETUP_TIMESTAMP_FILE)
    currenttime=$(date +%s%3N)
    timediff=$(echo "$teardown_finish_target_time - $currenttime" | bc) # milliseconds
    if [[ "$timediff" -gt 0 ]]; then
        sleeptime=$(echo "scale=3; $timediff/1000" | bc -l) # seconds
        echo "sleep $sleeptime"
        sleep "$sleeptime"
    fi

    aplay -q "$beep3" &
    while true; do
        read -rp "Your guess (1=i3, 2=sway): " guess </dev/tty
        case $guess in
            1 ) echo "  guess: i3" >> "$RESULTS_FILE"; break;;
            2 ) echo "  guess: sway" >> "$RESULTS_FILE"; break;;
            * ) echo "Please answer 1 or 2";;
        esac
    done
    aplay -q "$beep1" &
done <"$SEQUENCE_FILE"

echo "Results are stored in $RESULTS_FILE:"
cat "$RESULTS_FILE"
