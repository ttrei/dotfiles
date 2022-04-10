#!/usr/bin/env python3
import initworkspace

TIMEOUT = 2.0

WORKSPACE_PROGRAMS = {
    # workspace
    "100:test": [
        # execstr, window_name, window_class, window_handling_commands
        ["zutty -e sleep 1", "sleep", "zutty", None],
    ],
}

initworkspace.run(WORKSPACE_PROGRAMS, TIMEOUT)
