#!/usr/bin/env bash

SCRIPTDIR="$( cd "$(dirname "$0")" || exit >/dev/null 2>&1 ; pwd -P )"

# shellcheck disable=SC1091
source "$SCRIPTDIR/env.sh"

ssh reinis@localhost -p $QEMU_GUEST_PORT
