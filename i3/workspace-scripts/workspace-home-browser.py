#!/usr/bin/env python3

import os
import time

from i3ipc import Connection
from subprocess import Popen

i3 = Connection()

# NOTE: --no-auto-back-and-forth doesn't have the intended effect

# i3.command("workspace 000:spawn")

Popen(["firefox"])
time.sleep(3.0)
i3.command("move --no-auto-back-and-forth container to workspace 10:browser")

# i3.command("workspace back_and_forth")
