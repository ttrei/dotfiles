#!/usr/bin/env python3

import os
import time

from i3ipc import Connection
from subprocess import Popen

i3 = Connection()

path = os.path.join(os.environ.get("HOME"), "dev", "notes")
os.chdir(path)

Popen(["zutty"])
time.sleep(0.2)
i3.command("move container to workspace 05:notes")

Popen(["emacs"])
time.sleep(0.5)
i3.command("move container to workspace 05:notes")

# Popen(["zutty", "-e", "vim", "-p", "org/todo.org", "algorithms.adoc"])
# time.sleep(0.2)
# i3.command("move container to workspace 05:notes")
