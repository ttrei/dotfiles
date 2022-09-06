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

read -r -p "Make sure the VirtualBox Guest Additions CD is inserted and press any key..."

# `bash -x` needed to record commands+output of the called script
bash -x scripts/install_base.sh 2>&1 | tee "$LOGFILE"
bash -x scripts/install_gui.sh 2>&1 | tee -a "$LOGFILE"

scripts/setup_guest_additions.sh "$LOGFILE"
