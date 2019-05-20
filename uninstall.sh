#!/usr/bin/env bash

echo "Uninstalling dotfiles:"

echo "xfce4-terminal"
mkdir -p ~/.config/xfce4/
stow -D xfce4terminal -t ~/.config/xfce4/

echo "i3"
mkdir -p ~/.config/
stow -D i3 -t ~/.config/

echo "vim"
stow -D vim

echo "neovim"
mkdir -p ~/.config/
stow -D nvim -t ~/.config/

echo "bash"
stow -D bash

echo "git"
mkdir -p ~/.config/
stow -D git -t ~/.config/

echo "tmux"
stow -D tmux

echo "login"
stow -D login

echo "clang-format"
stow -D clang-format

echo "xorg"
stow -D xorg

echo "dunst"
mkdir -p ~/.config/
stow -D dunst -t ~/.config/
