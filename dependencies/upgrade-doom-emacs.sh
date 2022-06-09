#!/usr/bin/env sh

doom upgrade
doom sync
doom doctor

# If you get warnings about out-of-date .elc files, you may have to remove some files:
# https://github.com/doomemacs/doomemacs/issues/4171
