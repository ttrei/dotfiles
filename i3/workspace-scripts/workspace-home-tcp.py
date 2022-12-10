#!/usr/bin/env python3
import os

import i3init

TIMEOUT = 5.0

HOME = os.path.expanduser("~")
DEVDIR = f"{HOME}/dev/learn/tcp"

BOOK = "/media/storage-new/Stevens-TCP_IP_Illustrated_Volume_1_The_Protocols_1994.pdf"
BOOK2 = "/media/storage-new/books/LinuxProgrammingInterface.pdf"

WORKSPACE_PROGRAMS = {
    "15:doc": [
        [f"zathura {BOOK}", "org.pwmt.zathura", "zathura", None],
        [f"zathura {BOOK2}", "org.pwmt.zathura", "zathura", None],
    ],
    "20:dev": [
        [f"exec-in-dir {DEVDIR} zutty", "zutty-tcp", "zutty", None],
        [f"exec-in-dir {DEVDIR} zutty", "zutty-tcp", "zutty", None],
    ],
    "65:wireshark": [
        [f"wireshark", "the wireshark network analyzer", "wireshark", None],
    ],
}

i3init.run(WORKSPACE_PROGRAMS, TIMEOUT)
