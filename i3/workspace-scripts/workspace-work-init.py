#!/usr/bin/env python3

import os
import time

from i3ipc import Connection
from subprocess import Popen

i3 = Connection()

i3.command("workspace 000:spawn")


# Teams
Popen(["teams"])
time.sleep(10)
i3.command("move container to workspace 00:teams")


# OpenVPN
Popen(
    [
        "zutty",
        "-e",
        "sudo",
        "openvpn",
        "--config",
        "/etc/openvpn/client/work.conf",
    ]
)
time.sleep(0.3)
i3.command("move container to workspace 80:daemons")


# Lorri
Popen(
    [
        "zutty",
        "-e",
        "lorri",
        "daemon",
    ]
)
time.sleep(0.3)
i3.command("move container to workspace 80:daemons")


# Notes
path = os.path.join(os.environ.get("HOME"), "dev", "doc")
os.chdir(path)

Popen(["zutty"])
time.sleep(0.3)
i3.command("move container to workspace 30:notes")

path = os.path.join(os.environ.get("HOME"), "dev", "doc", "modules", "ROOT")
os.chdir(path)
Popen(
    ["zutty", "-e", "nvim", "-p", "pages/todo.adoc", "pages/done.adoc", "pages/log.adoc"]
)
time.sleep(0.3)
i3.command("move container to workspace 30:notes")


# Dev
path = os.path.join(os.environ.get("HOME"), "ips", "core")
os.chdir(path)

Popen(["zutty"])
time.sleep(0.3)
i3.command("move container to workspace 31:dev")
Popen(["zutty"])
time.sleep(0.3)
i3.command("move container to workspace 31:dev")

Popen(["idea"])
time.sleep(4)
i3.command("move container to workspace 35:idea")

Popen(["pycharm"])
time.sleep(4)
i3.command("move container to workspace 37:pycharm")


# Browser
Popen(["firefox"])
time.sleep(4)
i3.command("move container to workspace 25:browser")


# All done
i3.command("workspace 80:daemons")
