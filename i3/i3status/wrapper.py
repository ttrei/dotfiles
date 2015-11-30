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

def upgrade_count(json_line, filename):
    """ Prepend the number of pending upgrades """
    try:
        with open(filename) as fp:
            count = fp.readline().strip()
            if int(count) > 0:
                color = yellow
            else:
                color = green
    except:
        color = yellow
        count = "???"
    json_line.insert(0, {'full_text' : count, 'color' : color,
                     'name' : 'upgrades'})
    return json_line

def obnam_status(json_line):
    """ Prepend the status of obnam backups """
    now = datetime.datetime.now()
    files = ('/home/reinis/.status/obnam/last_backup_homedir',
             '/home/reinis/.status/obnam/last_backup_root')
    maxdiff = 0
    for f in files:
        try:
            with open(f) as fp:
                timestring = fp.readline().strip()
                if timestring == "": # Empty file
                    diff = -1
                else:
                    t = datetime.datetime.strptime(timestring, '%Y-%m-%d %H:%M:%S')
                    diff = (now - t).total_seconds() / 3600.0 # Difference in hours
        except: # couldn't open the file
            diff = -1

        if diff == -1 or maxdiff == -1: # An error has occured
            maxdiff = -1
        else:
            maxdiff = max(maxdiff, diff)

    message = str(int(maxdiff)) + 'h'
    if maxdiff > 72:
        color = red
    elif maxdiff > 48:
        color = yellow
    else:
        color = green

    json_line.insert(0, {'full_text' : message, 'color' : color, 'name' : 'obnam'})
    return json_line

def unison_status(json_line):
    """ Prepend the status of unison synchronized files """
    try:
        with open('/var/tmp/unison_changes') as fp:
            if int(fp.readline()) > 0:
                color = red # There are changes
            else:
                color = green # There are no changes
    except:
        color = yellow
    json_line.insert(0, {'full_text' : 'U', 'color' : color, 'name' : 'unison'})
    return json_line

def bitcoin_price(json_line):
    """ Prepend the dollar price of one bitcoin """
    try:
        with open('/tmp/bitcoin_price.txt') as fp:
            btcusd = fp.readline().strip()
            #usdbit = "%.0f" % (1e6 / float(btcusd))
    except IOError:
        json_line.insert(0, {'full_text' : 'getPrice not running', 'color' : red, 'name' : 'btc'})
    else:
        #json_line.insert(0, {'full_text' : '%sb' % usdbit, 'name' : 'bit'})
        if btcusd != '':
            json_line.insert(0, {'full_text' : '$%s' % btcusd, 'name' : 'btc'})

def dogecoin_price(json_line):
    """ Prepend the price of one dogecoin in satoshis """
    try:
        with open('/tmp/dogecoin_price.txt') as fp:
            value = fp.readline().strip()
    except:
        value = "???"
    json_line.insert(0, {'full_text' : '%ss' % value, 'name' : 'doge'})
    return json_line

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
            elif d['instance'] == '/media/Storage':
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

        # Add new information
        upgrade_count(j, '/var/tmp/upgrade_count_mazais.txt')
        upgrade_count(j, '/var/tmp/upgrade_count.txt')
        unison_status(j)
        obnam_status(j)
        bitcoin_price(j)
        dogecoin_price(j)

        colorize(j)

        # Encode to JSON and print to stdout
        print_line(prefix+json.dumps(j))
