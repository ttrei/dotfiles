#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Add additional git remote that points to upstream code.

# NOTE: This script would be great as a git hook but I didn't find a way to
# execute hook after submodule initialization.
# Currently the only use case for me is the zutty submodule under
# dev/exploration repo.
# Maybe use it as post-checkout hook?
# Preferably it should be executed only once, otherwise need additional logic to
# check that upstream remote does not exist.
# There may be problems with executing the hook immediately after fresh clone of
# a repo - even if we store the hook in the repo, it may be disabled by default.
# Needs more exploration/reading.

GITROOT=$(git rev-parse --show-toplevel)
GITUPSTREAM="$GITROOT/.gitupstream"
if [ -f "$GITUPSTREAM" ]; then
    upstream=$(head -n1 "$GITUPSTREAM")
    echo "Adding remote 'upstream' ($upstream)"
    git remote add upstream "$upstream"
else
    echo "$GITUPSTREAM missing"
fi
