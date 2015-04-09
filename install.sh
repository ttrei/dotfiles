#!/bin/bash

echo "Installing dotfiles:"

echo "xfce4-terminal"
mkdir -p ~/.config/xfce4/
stow xfce4terminal -t ~/.config/xfce4/
