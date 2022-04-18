#!/usr/bin/env python3
import os

import initworkspace

TIMEOUT = 5.0
HOME = os.path.expanduser("~")
WORKSPACE_PROGRAMS = {
    # workspace
    "85:dotfiles": [
        # execstr, window_name, window_class, window_handling_commands
        [f"terminal-at-dir {HOME}/dotfiles", "zutty-dotfiles", "zutty", None],
        [f"terminal-at-dir {HOME}/dotfiles", "zutty-dotfiles", "zutty", None],
    ],
}

initworkspace.run(WORKSPACE_PROGRAMS, TIMEOUT)
