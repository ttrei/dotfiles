#!/usr/bin/env sh

PATTERN=$1
if [ -z "$PATTERN" ]; then
    echo "Usage: $0 <pattern>"
    exit 1
fi

rg "$PATTERN" \
    --only-matching \
    --no-filename \
    --no-heading \
    --no-line-number \
| sort \
| uniq
