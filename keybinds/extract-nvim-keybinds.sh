#!/usr/bin/env sh

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
cd "$SCRIPT_DIR" || exit 1

suppress_nix_store_paths() {
    sed -i -E 's|/nix/store/[^-]*?|/nix/store/...|' "$1"
}

nvim -c ':CmdOutput nmap' -c 'wq! nvim-nmap.txt'
nvim -c ':CmdOutput imap' -c 'wq! nvim-imap.txt'
nvim -c ':CmdOutput vmap' -c 'wq! nvim-vmap.txt'

suppress_nix_store_paths "nvim-nmap.txt"
suppress_nix_store_paths "nvim-imap.txt"
suppress_nix_store_paths "nvim-vmap.txt"
