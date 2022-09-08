#!/bin/sh

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
CONFIG_DIR=$(realpath "$SCRIPT_DIR/../configs")
CONFIG_FILE="$HOME/.dotfiles-env"

if ! [ -d "$CONFIG_DIR" ]; then
    echo "$CONFIG_DIR not found"
    exit 1
fi

if [ -f "$CONFIG_FILE" ]; then
    echo "$CONFIG_FILE alrady exists"
    echo "Remove it if you want to select a different config"
    exit 0
fi

# File selection code copied from
# https://unix.stackexchange.com/a/511201/260131

set -- "$CONFIG_DIR"/*

while true; do
    i=0
    for pathname do
        i=$(( i + 1 ))
        printf '%d) %s\n' "$i" "$(basename "$pathname")" >&2
    done

    printf 'Select config, or 0 to exit: ' >&2
    read -r reply

    number=$(printf '%s\n' "$reply" | tr -dc '[:digit:]')

    if [ "$number" = "0" ]; then
        exit
    elif [ "$number" -gt "$#" ]; then
        echo 'Invalid choice, try again' >&2
    else
        break
    fi
done

shift "$(( number - 1 ))"
selected_file=$1

echo "cp $selected_file $CONFIG_FILE"
cp "$selected_file" "$CONFIG_FILE"
