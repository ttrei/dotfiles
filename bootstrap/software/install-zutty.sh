#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

sudo apt-get install -q -y \
build-essential \
pkg-config \
python3 \
libegl-dev \
libfreetype-dev \
libgles-dev \
libxmu-dev

sudo rm -rf /tmp/zutty
git clone https://github.com/tomscii/zutty.git /tmp/zutty
pushd /tmp/zutty

./waf configure
./waf

sudo ./waf install

popd
