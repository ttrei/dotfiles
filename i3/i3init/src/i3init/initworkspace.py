#!/usr/bin/env python3
import asyncio
import logging
from typing import Dict, List, Optional, Set, Tuple

from i3ipc import Con, Event, WindowEvent
from i3ipc.aio import Con as AioCon
from i3ipc.aio import Connection as AioConnection

TIMEOUT = 5.0


class Program:
    def __init__(
        self,
        workspace: str,
        execstr: str,
        window_name: str,
        window_class: str,
        window_handling_commands: Optional[List[str]] = None,
    ):
        self.workspace = workspace
        self.exec_tuple = self._parse_exec_string(execstr, window_name)
        self.window_name = window_name
        self.window_class = window_class
        self.window_handling_commands = window_handling_commands or []

    @staticmethod
    def _parse_exec_string(execstr: str, window_name: str) -> Tuple[str, ...]:
        binary = execstr.split()[0]
        argstr: str = execstr.lstrip(binary).strip()
        args = argstr.split()
        if binary == "exec-in-dir":
            if len(args) < 2:
                raise ValueError("exec-in-dir must have at least two arguments")
            directory, executable = args[0], args[1]
            args = args[2:]
            if executable == "zutty":
                args = ["-t", window_name] + args
            return binary, directory, executable, *args
        elif binary == "zutty":
            return binary, "-t", window_name, *args
        elif binary == "emacs":
            return binary, f"--title={window_name}", *args
        else:
            return binary, *args

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
        for execstr, window_name, window_class, window_handling_commands in program_args_list:
            program = Program(
                workspace, execstr, window_name, window_class, window_handling_commands
            )
            program_list.append(program)
        workspace_programs[workspace] = program_list
    return workspace_programs


async def on_new_window(i3: AioConnection, e: WindowEvent):
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
    i3 = await AioConnection(auto_reconnect=True).connect()

    # We will not touch already existing workspaces containing something
    nonempty_workspaces = get_nonempty_workspaces(await i3.get_tree())

    for workspace, programs in construct_workspace_programs(workspace_program_config).items():
        if workspace in nonempty_workspaces:
            continue
        for program in programs:
            try:
                await asyncio.create_subprocess_exec(*program.exec_tuple)
            except FileNotFoundError as e:
                logging.error(f"Couldn't execute {program.exec_tuple}: {e}")
                continue
            STARTING_PROGRAMS.add(program)

    if len(STARTING_PROGRAMS) == 0:
        return

    i3.on(Event.WINDOW_NEW, on_new_window)  # type: ignore

    await asyncio.wait_for(i3.main(), timeout=timeout)


def run(workspace_program_config, timeout):
    asyncio.run(main(workspace_program_config, timeout))


def get_nonempty_workspaces(tree: AioCon):
    nonempty_workspaces = set()
    outputs = [n for n in tree.nodes if n.name != "__i3"]
    for output in outputs:
        content = None
        for node in output.nodes:
            if node.type == "con" and node.name == "content":
                content = node
                break
        if content is None:
            raise RuntimeError(f"Couldn't find content node in {output.name} output")
        for node in content.nodes:
            if node.type != "workspace":
                raise RuntimeError(f"Unexpected node {node.name} of type {node.type}")
            if len(node.nodes) > 0:
                nonempty_workspaces.add(node.name)
    return nonempty_workspaces


def print_i3_nodes(node: Con, depth=0):
    print(f"{'  ' * depth}[{node.type}] {node.name}")
    for child_node in node.nodes:
        print_i3_nodes(child_node, depth + 1)
