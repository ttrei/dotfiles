#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y libxft-dev libharfbuzz-dev
git clone https://github.com/LukeSmithxyz/st /tmp/st
pushd /tmp/st
git checkout 03fe8634cd3f2f3cbd1679be84b465d63caafa3c
make
sudo make install
popd
sudo rm -rf /tmp/st
sudo DEBIAN_FRONTEND=noninteractive apt-get remove --purge -q -y libxft-dev libharfbuzz-dev
sudo DEBIAN_FRONTEND=noninteractive apt-get autopurge -q -y
