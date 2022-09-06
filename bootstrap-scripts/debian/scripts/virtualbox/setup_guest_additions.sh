#!/usr/bin/env bash

# TODO: Test this script (haven't executed it in a long time)

set -o errexit
set -o nounset
set -o pipefail

if [[ -z "$BOOTSTRAP_BASEDIR" ]]; then
    echo "BOOTSTRAP_BASEDIR not set" 1>&2
    exit 1
fi

sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y build-essential module-assistant expect
sudo expect "BOOTSTRAP_BASEDIR/scripts/virtualbox/prepare_for_guest_additions.ex"
sudo mount /media/cdrom
sudo sh /media/cdrom/VBoxLinuxAdditions.run
