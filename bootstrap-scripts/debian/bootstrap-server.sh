#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if ! id -nG "$USER" | grep -qw "sudo"; then
    echo "$USER does not belong to sudo group"
    exit 1
fi

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
cd "$SCRIPT_DIR"
export BOOTSTRAP_BASEDIR="$SCRIPT_DIR"

LOGFILE="$HOME/bootstrap_$(date +%FT%H-%M-%S).log"
echo -e "Output will be written to logfile:\n$LOGFILE"
read -rp "Press Enter to continue" </dev/tty

# `bash -x` needed to record commands+output of the called script
bash -x scripts/install_base.sh 2>&1 | tee "$LOGFILE"

cp files/grub /etc/default/grub
update-grub
