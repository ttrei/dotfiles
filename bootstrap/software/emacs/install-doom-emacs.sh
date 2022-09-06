#!/usr/bin/env sh

git clone https://github.com/hlissner/doom-emacs ~/.emacs.d
DOOMDIR=~/.config/doom ~/.emacs.d/bin/doom install
sudo apt install markdown # doom emacs needs a markdown compiler
