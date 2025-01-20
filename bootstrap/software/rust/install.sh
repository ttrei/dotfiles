#!/usr/bin/env sh

if ! [ -d /tmp/yek ]; then
    git clone https://github.com/bodo-run/yek.git /tmp/yek
fi
cargo install --path /tmp/yek --root /home/reinis/.cargo
