#!/usr/bin/env sh

sleep 1
windowid=$(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}')
winid="$(printf "%u\n" $windowid 2>/dev/null)"
i3-msg -q [id=\"$winid\"] "focus; fullscreen"
bash
