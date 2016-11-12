#!/usr/bin/env bash

echo "Installing dotfiles:"

echo "xfce4-terminal"
mkdir -p ~/.config/xfce4/
stow xfce4terminal -t ~/.config/xfce4/

echo "i3"
mkdir -p ~/.config/
stow i3 -t ~/.config/

echo "vim"
stow vim

echo "bash"
stow bash

echo "git"
mkdir -p ~/.config/
stow git -t ~/.config/

echo "tmux"
stow tmux

echo "login"
stow login
