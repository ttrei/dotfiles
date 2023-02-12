#!/usr/bin/env python
# De-duplicate bash history, keeping the most recent occurrences of unique commands.
# Inspired by https://superuser.com/a/1436733/1772509

import sys

if len(sys.argv) < 3:
    print(f"Usage: {sys.argv[0]} <input file> <output file>")
    sys.exit(1)

unique_lines = set()
output = []

input_file = sys.argv[1]
output_file = sys.argv[2]

with open(input_file, 'rb') as f:
    for line in reversed(f.readlines()):
        if line not in unique_lines:
            unique_lines.add(line)
            output.append(line)

with open(output_file, 'wb') as f:
    f.writelines(reversed(output))
