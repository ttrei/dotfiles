#!/usr/bin/env python
# -*- coding: utf-8 -*-

# This script is used to enhance the output of i3status with additional
# information. i3status continuously outputs a JSON line. We read and decode
# that line, add new information, encode to JSON and print the new line.

# Usage
#
# Ensure your ~/.config/i3status/.i3status.conf contains this line:
#     output_format = "i3bar"
# in the 'general' section.
# Then, in your ~/.i3/config, use:
#     status_command i3status | ~/.config/i3status/wrapper.py
# In the 'bar' section.

import sys
import json
import datetime

green =  "#00FF00"
red =    "#FF0000"
yellow = "#FFFF00"

def print_line(message):
    """ Non-buffered printing to stdout. """
    sys.stdout.write(message + '\n')
    sys.stdout.flush()

def read_line():
    """ Interrupted respecting reader for stdin. """
    # try reading a line, removing any extra whitespace
    try:
        line = sys.stdin.readline().strip()
        # i3status sends EOF, or an empty line
        if not line:
            sys.exit(3)
        return line
    # exit on ctrl-c
    except KeyboardInterrupt:
        sys.exit()

# Colorize output of `i3status`
def colorize(j):
    for d in j:
        if d['name'] == 'disk_info':
            if d['instance'] == '/':
                d[u'color'] = u'#ffc0c0'
            elif d['instance'] == '/var':
                d[u'color'] = u'#fffdba'
            elif d['instance'] == '/home':
                d[u'color'] = u'#c7cdff'
        elif d[u'name'] == 'cpu_usage':
            load = int(d['full_text'].strip('%'))
            if load > 89:
                d[u'color'] = red
            elif load > 29:
                d[u'color'] = yellow


if __name__ == '__main__':
    # Skip the first line which contains the version header.
    print_line(read_line())

    # The second line contains the start of the infinite array.
    print_line(read_line())

    while True:
        # Wait for i3status to produce a line, then read it
        line, prefix = read_line(), ''
        # i3status prepends a comma to subsequent lines
        if line.startswith(','):
            line, prefix = line[1:], ','

        # Decode the line
        j = json.loads(line)

        colorize(j)

        # Encode to JSON and print to stdout
        print_line(prefix+json.dumps(j))
