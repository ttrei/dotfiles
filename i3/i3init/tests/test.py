#!/usr/bin/env python3
import os

import i3init
from i3init import Program, Workspace

HOME = os.path.expanduser("~")

workspace1 = Workspace("100:test").with_programs(
    Program(
        exec_cmd=f"exec-in-dir {HOME}/dotfiles zutty -e sleep 999999",
        window_handling_commands=["move left"],
    ),
    Program(
        exec_cmd=f"exec-in-dir {HOME}/dotfiles zutty -e sleep 3",
        window_handling_commands=["move to workspace 101:test"],
    ),
)

workspace2 = Workspace("200:dev").with_programs(
    Program(exec_cmd="ghostty"),
    Program(exec_cmd="zutty"),
)

i3init.run([workspace1, workspace2], timeout=2.0)
