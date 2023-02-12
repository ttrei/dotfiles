#!/usr/bin/env python3
# De-duplicate bash history, keeping the most recent occurrences of unique commands.
# Inspired by https://superuser.com/a/1436733/1772509

import os
import sys

if len(sys.argv) < 2:
    print(f"Usage: {sys.argv[0]} <bash history file>")
    sys.exit(1)

unique_lines = set()
output = []

history_file_path = sys.argv[1]
deduplicated_file_path = history_file_path + "-deduplicated.tmp"

with open(history_file_path, 'rb') as f:
    for line in reversed(f.readlines()):
        if line not in unique_lines:
            unique_lines.add(line)
            output.append(line)

with open(deduplicated_file_path, 'wb') as f:
    f.writelines(reversed(output))

os.replace(deduplicated_file_path, history_file_path)
