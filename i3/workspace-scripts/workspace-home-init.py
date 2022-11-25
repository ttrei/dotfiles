#!/usr/bin/env python3

import i3init

TIMEOUT = 5.0

WORKSPACE_PROGRAMS = {
    # workspace
    "05:notes": [
        # execstr, window_name, window_class, window_handling_commands
        ["emacs", "emacs-notes", "emacs", ["move right"]],
        ["zutty", "zutty-notes", "zutty", None],
    ],
    "10:browser": [
        ["firefox", "mozilla firefox", "firefox", None],
    ],
}

i3init.run(WORKSPACE_PROGRAMS, TIMEOUT)
