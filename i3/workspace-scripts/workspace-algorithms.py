#!/usr/bin/env python3

# https://github.com/swaywm/sway/issues/1005
# https://github.com/altdesktop/i3ipc-python

import os
import time

from i3ipc import Connection
from subprocess import Popen

i3 = Connection()

os.chdir("/home/reinis/dev/exploration/zig")
Popen(["zutty"])
time.sleep(0.1)
i3.command("move container to workspace 21:zig")

Popen(["evince", "/media/storage-new/Skiena-The_Algorithm_Design_Manual-2020.pdf"])
time.sleep(0.5)
i3.command("move container to workspace 15:doc")
