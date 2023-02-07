#!/usr/bin/env bash

# Detect connected displays and export their xrandr outputs as env variables
# Adapted from https://stackoverflow.com/a/24933353/9124671

tmpfile=$(mktemp)
while read -r output hex conn; do
    [[ -z "$conn" ]] && conn=${output%%-*}
    echo "$(xxd -r -p <<< "$hex") $output" >> $tmpfile
done < <(xrandr --prop | awk '
    !/^[ \t]/ {
        if (output && hex) print output, hex, conn
        output=$1
        hex=""
    }
    /ConnectorType:/ {conn=$2}
    /[:.]/ && h {
        sub(/.*000000fc00/, "", hex)
        hex = substr(hex, 0, 26) "0a"
        sub(/0a.*/, "", hex)
        h=0
    }
    h {sub(/[ \t]+/, ""); hex = hex $0}
    /EDID.*:/ {h=1}
    END {if (output && hex) print output, hex, conn}
    ' | sort
)

PRIMARY_DISPLAY=$(grep VG245 "$tmpfile" | cut -d" " -f2)
SECONDARY_DISPLAY=$(grep S23C650 "$tmpfile" | cut -d" " -f2)
export PRIMARY_DISPLAY
export SECONDARY_DISPLAY

rm "$tmpfile"
