#!/usr/bin/env python3
import os

import i3init

TIMEOUT = 5.0
HOME = os.path.expanduser("~")
WORKSPACE_PROGRAMS = {
    # workspace
    "85:dotfiles": [
        # execstr, window_name, window_class, window_handling_commands
        [f"exec-in-dir {HOME}/dotfiles zutty", "zutty-dotfiles", "zutty", None],
        [f"exec-in-dir {HOME}/dotfiles zutty", "zutty-dotfiles", "zutty", None],
    ],
}

i3init.run(WORKSPACE_PROGRAMS, TIMEOUT)
