#!/usr/bin/env python3

# https://github.com/swaywm/sway/issues/1005
# https://github.com/altdesktop/i3ipc-python

import os
import time

from i3ipc import Connection
from subprocess import Popen

i3 = Connection()

path = os.path.join(os.environ.get("HOME"), "dev", "exploration", "zig")
os.chdir(path)

Popen(["zutty"])
time.sleep(0.1)
i3.command("move container to workspace 21:zig")

book = "/media/storage-new/Skiena-The_Algorithm_Design_Manual-2020.pdf"
Popen(["evince", book])
time.sleep(0.5)
i3.command("move container to workspace 15:doc")
