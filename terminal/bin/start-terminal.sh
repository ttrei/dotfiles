#!/usr/bin/env bash

if command -v ghostty >/dev/null 2>&1; then
    TERMINAL_CMD="ghostty"
elif command -v zutty >/dev/null 2>&1; then
    TERMINAL_CMD="zutty"
elif command -v st >/dev/null 2>&1; then
    TERMINAL_CMD="st"
else
    TERMINAL_CMD="xterm"
fi

if [ "$1" != "--samecwd" ]; then
    $TERMINAL_CMD "$@" &
    exit 0
fi

# Remove the first argument ("samecwd")
shift

# Try to determine the PWD of the focused terminal and pass it to the newly spawned one.
# Adapted from a similar script that works on sway (attached at the end).
# https://blog.freesources.org//posts/2019/12/switch_to_sway/
# i3-msg -t get_tree doesn't report PIDs, so we used xprop instead.

export START_CWD="$HOME"

function get_child_pid() {
    if [ -z "$1" ]; then
        echo ""
        return
    fi
    CHILD_PID="$(ps -o pid= --ppid "$1" | head -n1 | awk '{print $1}')"
    case "$CHILD_PID" in
        ''|*[!0-9]*)
            echo "$0: CHILD_PID=$CHILD_PID is not integer"
            CHILD_PID=""
        ;;
        *) ;; # OK, integer
    esac
    echo "$CHILD_PID"
}

WINDOWID=""
WINDOWID=$(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}')
WMCLASS=""
if [ -n "$WINDOWID" ]; then
    WMCLASS=$(xprop -id "$WINDOWID" | awk -F'"' '/WM_CLASS\(STRING\)/{print $2}')
fi
if [ "$WMCLASS" != "Zutty" ] &&[ "$WMCLASS" != "ghostty" ] && [ "$WMCLASS" != "xterm-256color" ]; then
    # Focused window is not a terminal. Start at default CWD.
    $TERMINAL_CMD "$@" &
    exit 0
fi

TERM_PID=$(xprop -id "$WINDOWID" | awk '/_NET_WM_PID\(CARDINAL\)/{print $NF}')
case "$TERM_PID" in
    ''|*[!0-9]*)
        echo "$0: TERM_PID=$TERM_PID is not integer"
        TERM_PID=""
    ;;
    *) ;; # OK, integer
esac

SHELL_PID=""
if [ -n "$TERM_PID" ]; then
    SHELL_PID=$(get_child_pid "$TERM_PID")
    # st now spawns a `scroll` process
    # st───scroll───bash
    #SHELL_PID=$(get_child_pid "$SHELL_PID")
fi

CURRENT_CWD=""
if [ -n "$SHELL_PID" ]; then
    CURRENT_CWD="$(readlink "/proc/$SHELL_PID/cwd")"
fi

if [ -d "$CURRENT_CWD" ]; then
    START_CWD="$CURRENT_CWD" $TERMINAL_CMD "$@" &
else
    # Could not determine current CWD. Start at default CWD.
    $TERMINAL_CMD "$@" &
fi

# https://blog.freesources.org//posts/2019/12/switch_to_sway/
#
# #!/bin/sh
#
# # Small script that tries to determine the PWD of the focused terminal
# # (in sway tiling window manager) and pass it to the newly spawned one.
#
# TERMINAL_CMD="tilix --new-process"
#
# FOCUSED_PID=""
# if [ ! type jq 2>/dev/null ]; then
#     echo "ERROR: jq not installed" >&2
# else
#     FOCUSED_PID="$(swaymsg -t get_tree | jq '.. | select(.type?) |
#         select(.type=="con") | select(.focused==true).pid')"
# fi
#
# FOCUSED_PWD=""
# # Check if $FOCUSED_PID is an integer
# if [ "$FOCUSED_PID" -eq "$FOCUSED_PID" 2>/dev/null ]; then
#     FOCUSED_PPID="$(ps -o pid= --ppid "$FOCUSED_PID" | awk '{print $1}')"
#     if [ "$FOCUSED_PPID" -eq "$FOCUSED_PPID" 2>/dev/null ]; then
#         FOCUSED_PWD="$(readlink "/proc/$FOCUSED_PPID/cwd")"
#     fi
# fi
#
# # Spawn terminal in background
# if [ -d "$FOCUSED_PWD" ]; then
#     $TERMINAL_CMD --working-directory="$FOCUSED_PWD" $@ &
# else
#     $TERMINAL_CMD $@ &
# fi
