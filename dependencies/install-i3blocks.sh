#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y automake autotools-dev
git clone https://github.com/vivien/i3blocks /tmp/i3blocks
pushd /tmp/i3blocks
./autogen.sh
./configure
make
sudo make install
popd
rm -rf /tmp/i3blocks
sudo DEBIAN_FRONTEND=noninteractive apt-get remove --purge -q -y automake autotools-dev
sudo DEBIAN_FRONTEND=noninteractive apt-get autopurge -q -y
