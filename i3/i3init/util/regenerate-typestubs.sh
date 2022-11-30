#!/usr/bin/env sh

# Re-generate type stubs with pyright and re-apply our adjustments.
# If the patch doesn't apply cleanly, consider skipping the "patch" step and
# using git resolve the conflicts. Don't forget to re-create the patch file with
# create-typestub-diff.sh.

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

cd "$SCRIPT_DIR/.." || exit

rm -rf typings
pyright --createstub i3ipc
isort typings
black typings

patch -s -p0 < typings.patch

