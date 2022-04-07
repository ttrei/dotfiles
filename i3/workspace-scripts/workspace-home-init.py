#!/usr/bin/env python3
import asyncio
from typing import Set

from i3ipc import Event
from i3ipc.aio import Connection
from i3ipc.events import WindowEvent

from program import Program, construct_workspace_programs

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
    "20:dev": [
        ["zutty", "zutty-dev", "zutty", None],
        ["zutty", "zutty-dev", "zutty", None],
    ],
}

STARTING_PROGRAMS: Set[Program] = set()


async def on_new_window(i3: Connection, e: WindowEvent):
    _ = i3
    window_name = e.container.name
    window_class = e.container.window_class

    print(f"on_new_window: {window_name=}, {window_class=}")

    matched_program = None
    for program in STARTING_PROGRAMS:
        if program.match(window_name, window_class):
            matched_program = program
            break
    if matched_program is None:
        return

    STARTING_PROGRAMS.remove(matched_program)
    await e.container.command(f"move to workspace {matched_program.workspace}")
    for command in matched_program.window_handling_commands:
        await e.container.command(command)

    if len(STARTING_PROGRAMS) == 0:
        i3.main_quit()


async def main():
    i3 = await Connection(auto_reconnect=True).connect()

    # We will not touch already existing workspaces
    existing_workspaces = {w.name for w in await i3.get_workspaces()}

    for workspace, programs in construct_workspace_programs(WORKSPACE_PROGRAMS).items():
        if workspace in existing_workspaces:
            continue
        for program in programs:
            await asyncio.create_subprocess_exec(*program.get_exec_tuple())
            STARTING_PROGRAMS.add(program)

    if len(STARTING_PROGRAMS) == 0:
        return

    i3.on(Event.WINDOW_NEW, on_new_window)

    await asyncio.wait_for(i3.main(), timeout=TIMEOUT)


asyncio.run(main())
