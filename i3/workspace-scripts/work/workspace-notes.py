#!/usr/bin/env python3

import os
import time

from i3ipc import Connection
from subprocess import Popen

i3 = Connection()

path = os.path.join(os.environ.get("HOME"), "dev", "doc")
os.chdir(path)

Popen(["zutty"])
time.sleep(0.1)
i3.command("move container to workspace 30:notes")


path = os.path.join(os.environ.get("HOME"), "dev", "doc", "modules", "ROOT")
os.chdir(path)
Popen([
    "zutty",
    "-e",
    "vim",
    "-p",
    "pages/todo.adoc",
    "pages/done.adoc",
    "pages/log.adoc"
])
time.sleep(0.1)
i3.command("move container to workspace 30:notes")
