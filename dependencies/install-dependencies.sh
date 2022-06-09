#!/usr/bin/env sh

cargo install $(cat rust-tools.txt)

git clone https://github.com/hlissner/doom-emacs ~/.emacs.d
DOOMDIR=~/.config/doom ~/.emacs.d/bin/doom install
sudo apt install markdown # doom emacs needs a markdown compiler
