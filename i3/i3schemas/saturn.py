#!/usr/bin/env python3
import os

from i3init import Program, Workspace

TIMEOUT = 5.0

HOME = os.path.expanduser("~")

I3SCHEMAS = {
    "kodi": [Workspace("05:kodi").with_programs(Program("kodi"))],
    "firefox": [
        Workspace("10:firefox").with_programs(Program("firefox", commands=["layout tabbed"], timeout_extra_windows=2)),
    ],
    "chromium": [
        Workspace("15:chrome").with_programs(Program("chromium", commands=["layout tabbed"], timeout_extra_windows=2)),
    ],
    "spotify": [
        Workspace("50:spotify").with_programs(Program("spotify")),
    ],
    "steam": [
        Workspace("90:steam").with_programs(Program("exec-in-dir {HOME} steam")),
    ],
    "lutris": [
        # NOTE: If we don't use "exec-in-dir", Lutris gets killed when this script exits.
        # TODO(2025-01-22): Check if still true after the refactor.
        Workspace("91:lutris").with_programs(Program("exec-in-dir {HOME} lutris")),
    ],
    # TODO: Create a script for launching retroarch.
    # Previously I used this command: steam-offline -applaunch 1118310"
    "retroarch": [
        Workspace("92:retroarch").with_programs(Program("retroarch")),
    ],
}
