#!/usr/bin/env python3
import asyncio
from typing import Set

from i3ipc import Event
from i3ipc.aio import Connection
from i3ipc.events import WindowEvent

from typing import Dict, List

TIMEOUT = 5.0


class Program:
    def __init__(self, execstr: str, window_name, window_class, window_handling_commands):
        self.binary = execstr.split()[0]
        self.argstr: str = execstr.lstrip(self.binary).strip()
        self.window_name = window_name
        self.window_class = window_class
        self.window_handling_commands = window_handling_commands or []
        self.workspace = None

    def get_exec_tuple(self):
        args = self.argstr.split()
        if self.binary == "zutty":
            return self.binary, "-t", self.window_name, *args
        elif self.binary == "emacs":
            return self.binary, f"--title={self.window_name}", *args
        else:
            return self.binary, *args

    def match(self, window_name: str, window_class: str):
        if self.window_name == window_name.lower() and self.window_class == window_class.lower():
            return True
        else:
            return False


def construct_workspace_programs(workspace_program_config: dict):
    # Convert from configuration dict to Program objects
    workspace_programs: Dict[str, List[Program]] = {}
    for workspace, program_args_list in workspace_program_config.items():
        program_list = []
        for args in program_args_list:
            program = Program(*args)
            program.workspace = workspace
            program_list.append(program)
        workspace_programs[workspace] = program_list
    return workspace_programs


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


STARTING_PROGRAMS: Set["Program"] = set()


async def main(workspace_program_config, timeout):
    i3 = await Connection(auto_reconnect=True).connect()

    # We will not touch already existing workspaces
    existing_workspaces = {w.name for w in await i3.get_workspaces()}

    for workspace, programs in construct_workspace_programs(workspace_program_config).items():
        if workspace in existing_workspaces:
            continue
        for program in programs:
            await asyncio.create_subprocess_exec(*program.get_exec_tuple())
            STARTING_PROGRAMS.add(program)

    if len(STARTING_PROGRAMS) == 0:
        return

    i3.on(Event.WINDOW_NEW, on_new_window)

    await asyncio.wait_for(i3.main(), timeout=timeout)


def run(workspace_program_config, timeout):
    asyncio.run(main(workspace_program_config, timeout))
