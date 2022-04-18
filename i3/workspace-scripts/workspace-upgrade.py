#!/usr/bin/env python3
import initworkspace

TIMEOUT = 2.0
WORKSPACE_PROGRAMS = {
    # workspace
    "95:upgrade": [
        # execstr, window_name, window_class, window_handling_commands
        ["zutty", "zutty-upgrade", "zutty", None],
    ],
}

initworkspace.run(WORKSPACE_PROGRAMS, TIMEOUT)
