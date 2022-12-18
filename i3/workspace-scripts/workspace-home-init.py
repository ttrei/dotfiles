#!/usr/bin/env python3

import os

import i3init

TIMEOUT = 5.0

HOME = os.path.expanduser("~")

WORKSPACE_PROGRAMS = {
    # workspace
    "05:notes": [
        # execstr, window_name, window_class, window_handling_commands
        ["emacs", "emacs-notes", "emacs", ["move right"]],
        [f"exec-in-dir {HOME}/dev/notes zutty", "zutty-notes", "zutty", None],
    ],
    "10:browser": [
        ["firefox", "mozilla firefox", "firefox", None],
    ],
}

i3init.run(WORKSPACE_PROGRAMS, TIMEOUT)
