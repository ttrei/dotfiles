#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

cd ~
git clone ssh://reinis@taukulis.lv:/home/reinis/gitrepos/dotfiles.git

cd ~
git clone ssh://reinis@taukulis.lv:/home/reinis/.password-store.git
