#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# sudo dpkg --add-architecture i386
sudo DEBIAN_FRONTEND=noninteractive apt-get update -q
sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
clang-format \
cmake \
evince \
fd-find \
fonts-font-awesome \
jq \
libfreetype6-dev \
libglew-dev \
libglm-dev \
libsdl2-dev \
libsdl2-image-dev \
libsdl2-ttf-dev \
moreutils \
ninja-build \
#libboost-all-dev \
#rapid-photo-downloader \
#rawtherapee \

./install-zutty.sh
./install-i3blocks.sh

# # Debian-supplied Maven 3.6.3 throws some warnings, so download the upstream binaries
# # (see https://stackoverflow.com/a/63876216/9124671)
# pushd /opt
# wget https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
# tar -xf apache-maven-3.6.3-bin.tar.gz
# rm apache-maven-3.6.3-bin.tar.gz
# sudo update-alternatives --install /usr/bin/mvn mvn /opt/apache-maven-3.6.3/bin/mvn 363
# sudo update-alternatives --config mvn
# popd
