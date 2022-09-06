#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ -z "$BOOTSTRAP_BASEDIR" ]]; then
    echo "BOOTSTRAP_BASEDIR not set" 1>&2
    exit 1
fi

sudo DEBIAN_FRONTEND=noninteractive apt-get update -q
sudo DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
rapid-photo-downloader \
rawtherapee \
