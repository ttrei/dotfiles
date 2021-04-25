#!/usr/bin/env bash

N=3

# https://freesound.org/people/thisusernameis/sounds/426888/
beep1="$HOME/Downloads/beep1.wav"
# https://freesound.org/people/Eponn/sounds/528867/
beep2="$HOME/Downloads/beep2.wav"

RESULTS_FILE=/var/tmp/doubleblind-results.txt
SEQUENCE_FILE=/var/tmp/doubleblind-sequence.txt
SETUP_TIMESTAMP_FILE=/tmp/doubleblind-testcase-setup-starttime.txt

# Generate the testing sequence
rm -f "$SEQUENCE_FILE.tmp"
for i in $(seq 1 $N)
do
    echo "$i" > /dev/null # Shut up shellcheck
    echo "i3" >> "$SEQUENCE_FILE.tmp"
    echo "sway" >> "$SEQUENCE_FILE.tmp"
done
shuf "$SEQUENCE_FILE.tmp" > "$SEQUENCE_FILE"

# Perform testing
rm -f "$RESULTS_FILE"
while read -r line; do
    aplay -q "$beep1" &
    read -rp "Press ENTER to start next test" </dev/tty
    date +%s%3N > "$SETUP_TIMESTAMP_FILE" # milliseconds since epoch
    echo "$line" >> "$RESULTS_FILE"

    # setup-testing-env.sh will be executed on startup
    # (configured in i3 and sway configs)
    if [ "i3" == "$line" ]; then
        startx -- vt1 2>/dev/null
    elif [ "sway" == "$line" ]; then
        sway 1>/dev/null 2>&1
    fi

    while true; do
        read -rp "Your guess (1=i3, 2=sway): " guess </dev/tty
        case $guess in
            1 ) echo "  guess: i3" >> "$RESULTS_FILE"; break;;
            2 ) echo "  guess: sway" >> "$RESULTS_FILE"; break;;
            * ) echo "Please answer 1 or 2";;
        esac
    done

    aplay -q "$beep2" &
    sleep 1
done <"$SEQUENCE_FILE"

echo "Results are stored in $RESULTS_FILE:"
cat "$RESULTS_FILE"
