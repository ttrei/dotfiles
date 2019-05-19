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

DARKGRAY = "#444444"
GREEN    = "#00FF00"
RED      = "#FF0000"
YELLOW   = "#FFFF00"

def print_line(message):
    sys.stdout.write(message + '\n')
    sys.stdout.flush()

def read_line():
    try:
        line = sys.stdin.readline().strip()
        # i3status sends EOF, or an empty line
        if not line:
            sys.exit(3)
        return line
    except KeyboardInterrupt:
        sys.exit()

def error(message):
    return [{
        u'name': u'error',
        u'markup': u'none',
        u'full_text': message,
        u'color': RED,
    }]

def get_upgrade_counts():
    try:
        f = open('/var/tmp/upgrade_counts.json', 'r')
        strdata = f.read()
        f.close()
    except IOError:
        return error('Could not read /var/tmp/upgrade_counts.json')

    try:
        data = json.loads(strdata)
    except ValueError:
        return error('/var/tmp/upgrade_counts.json contains invalid JSON')

    res = []
    for entry in data:
        count = int(entry.get('count', -1))
        if count == 0:
            color = GREEN
        elif count > 0:
            color = YELLOW
        else:
            color = DARKGRAY
        res.append({
            u'name': u'upgrade_count',
            u'markup': u'none',
            u'host': entry['host'],
            u'full_text': "%s: %d" % (entry['host'], count),
            u'color': color,
        })
    return res

# Colorize output of `i3status`
def colorize(j):
    for d in j:
        name = d.get('name', None)
        instance = d.get('instance', None)
        if name == 'disk_info':
            if instance == '/':
                d[u'color'] = u'#ffc0c0'
            elif instance == '/var':
                d[u'color'] = u'#fffdba'
            elif instance == '/home':
                d[u'color'] = u'#c7cdff'
        elif name == 'cpu_usage':
            load = int(d['full_text'].strip('%'))
            if load > 89:
                d[u'color'] = RED
            elif load > 29:
                d[u'color'] = YELLOW

if __name__ == '__main__':
    # First line contains the version header
    print_line(read_line())
    # Second line contains starts the infinite array
    print_line(read_line())

    while True:
        line, prefix = read_line(), ''
        # i3status prepends a comma to subsequent lines
        if line.startswith(','):
            line, prefix = line[1:], ','

        # Decode the line
        j = json.loads(line)

        upgrade_counts = get_upgrade_counts()
        if upgrade_counts:
            j = upgrade_counts + j

        colorize(j)

        # Encode to JSON and print to stdout
        print_line(prefix+json.dumps(j))
