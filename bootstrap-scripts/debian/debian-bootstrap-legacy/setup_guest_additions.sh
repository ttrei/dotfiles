#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y build-essential module-assistant expect
sudo expect prepare_for_guest_additions.ex
sudo mount /media/cdrom
sudo sh /media/cdrom/VBoxLinuxAdditions.run
