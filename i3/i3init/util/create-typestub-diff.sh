#!/usr/bin/env sh

# Create a patch to record our changes of the pyright-generate type stubs.

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

cd "$SCRIPT_DIR/.." || exit

cp -r typings typings.patched
rm -rf typings
pyright --createstub i3ipc
isort typings
black typings

diff -ruN typings typings.patched > typings.patch

rm -rf typings.patched
git restore typings
