#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# TODO: Can we just get maven from nixpkgs?

# Debian-supplied Maven 3.6.3 throws some warnings, so download the upstream binaries
# (see https://stackoverflow.com/a/63876216/9124671)
pushd /opt
sudo wget https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
sudo tar -xf apache-maven-3.6.3-bin.tar.gz
sudo rm apache-maven-3.6.3-bin.tar.gz
sudo update-alternatives --install /usr/bin/mvn mvn /opt/apache-maven-3.6.3/bin/mvn 363
sudo update-alternatives --config mvn
popd
