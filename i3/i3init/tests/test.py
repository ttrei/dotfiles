#!/usr/bin/env python3
import os

import i3init
from i3init import Program, Workspace

HOME = os.path.expanduser("~")

workspace1 = Workspace("100:test").with_programs(
    Program(
        f"exec-in-dir {HOME}/dotfiles zutty -e sleep 999999",
        commands=["move left"],
    ),
    Program(
        f"exec-in-dir {HOME}/dotfiles zutty -e sleep 3",
        commands=["move to workspace 101:test"],
        timeout_extra_windows=2,
    ),
)

workspace2 = Workspace("200:dev").with_programs(
    Program("ghostty"),
    Program("zutty"),
)

workspace3 = Workspace("300:firefox").with_programs(
    Program("firefox", commands=["layout tabbed"], timeout_extra_windows=2),
)

i3init.run(
    [
        workspace1,
        # workspace2,
        # workspace3,
    ],
    timeout=5.0,
)
