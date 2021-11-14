#!/usr/bin/env sh

cd "$HOME/dev/notes"
zutty &
zutty -e vim TODO.adoc &
