#!/usr/bin/env sh

# Detect connected displays and export their xrandr outputs as env variables
# Adapted from https://stackoverflow.com/a/24933353/9124671

tmp1=$(mktemp)
xrandr --prop | awk '
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
' | sort > "$tmp1"

tmp2=$(mktemp)
while read -r output hex conn; do
    [ -z "$conn" ] && conn=${output%%-*}
    id=$(echo "$hex" | xxd -r -p)
    echo "$id" "$output" >> "$tmp2"
done < "$tmp1"
rm "$tmp1"

PRIMARY_DISPLAY=$(grep VG245 "$tmp2" | cut -d" " -f2)
SECONDARY_DISPLAY=$(grep S23C650 "$tmp2" | cut -d" " -f2)
export PRIMARY_DISPLAY
export SECONDARY_DISPLAY

rm "$tmp2"
