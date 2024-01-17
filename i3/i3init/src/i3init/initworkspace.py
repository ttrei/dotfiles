#!/usr/bin/env python3
import asyncio
import logging
from typing import Any, Dict, List, Optional, Set, Tuple

from i3ipc import Con, Connection, Event, WindowEvent
from i3ipc.aio import Con as AioCon
from i3ipc.aio import Connection as AioConnection

TIMEOUT = 5.0


class Program:
    def __init__(
        self,
        index_in_workspace: int,
        workspace: str,
        exec_list: list,
        window_name: str,
        window_class: str,
        window_handling_commands: Optional[List[str]] = None,
    ):
        self.index_in_workspace = index_in_workspace
        self.workspace = workspace
        self.exec_tuple = self._parse_exec_string(exec_list, window_name)
        self.window_name = window_name
        self.window_class = window_class
        self.window_handling_commands = window_handling_commands or []
        self.container: Any = None

    @staticmethod
    def _parse_exec_string(exec_list: list, window_name: str) -> Tuple[str, ...]:
        binary = exec_list[0]
        args = exec_list[1:]
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
        if self.window_name is None:
            return self.equals_case_insensitive(self.window_class, window_class)
        if self.window_class is None:
            return self.equals_case_insensitive(self.window_name, window_name)
        return self.equals_case_insensitive(self.window_class, window_class) and self.equals_case_insensitive(
            self.window_name, window_name
        )

    @staticmethod
    def equals_case_insensitive(left: str, right: str):
        if left is None or right is None:
            return False
        return left.lower() == right.lower()


def construct_workspace_programs(workspace_program_config: dict):
    # Convert from configuration dict to Program objects
    workspace_programs: Dict[str, List[Program]] = {}
    for workspace, program_args_list in workspace_program_config.items():
        program_list = []
        for i, (exec_list, window_name, window_class, window_handling_commands) in enumerate(program_args_list):
            program = Program(i, workspace, exec_list, window_name, window_class, window_handling_commands)
            program_list.append(program)
        workspace_programs[workspace] = program_list
    return workspace_programs


async def on_new_window(i3: AioConnection, e: WindowEvent):
    _ = i3
    print(f"on_new_window: window_name={e.container.name}, window_class={e.container.window_class}")

    global STARTING_PROGRAMS
    global WORKSPACE_PROGRAMS_STARTED

    try:
        workspace, matched_program = match_program(e)
    except UnmatchedProgramError:
        print("WARNING: Unmatched program")
        return

    print(f"Moving {matched_program.window_name}, {matched_program.window_class} " f"to {matched_program.workspace}")
    print(f"{matched_program.window_handling_commands=}")
    await e.container.command(f"move to workspace {matched_program.workspace}")

    programs_started = WORKSPACE_PROGRAMS_STARTED.setdefault(workspace, set())
    matched_program.container = e.container
    programs_started.add(matched_program)
    STARTING_PROGRAMS[workspace].remove(matched_program)
    if len(STARTING_PROGRAMS[workspace]) == 0:
        print(f"All programs in {workspace=} started")
        for program in sorted(programs_started, key=lambda p: p.index_in_workspace):
            print(f"Executing window handling commands for {program.window_name}")
            for command in program.window_handling_commands:
                print(f"{command =}")
                await program.container.command(command)
        print(f"Removing {workspace} from STARTING_PROGRAMS")
        STARTING_PROGRAMS.pop(workspace)

    if len(STARTING_PROGRAMS) == 0:
        i3.main_quit()


def match_program(e: WindowEvent):
    global STARTING_PROGRAMS
    window_name = e.container.name
    window_class = e.container.window_class
    for workspace, programs in STARTING_PROGRAMS.items():
        for program in programs:
            print(f"Matching {window_name=}, {window_class=} against {program.window_name}, {program.window_class}")
            if program.match(window_name, window_class):
                print("Matched")
                return workspace, program
    raise UnmatchedProgramError


class UnmatchedProgramError(Exception):
    pass


STARTING_PROGRAMS: Dict[str, Set["Program"]] = {}
WORKSPACE_PROGRAMS_STARTED: Dict[str, Set["Program"]] = {}


async def main(workspace_program_config, timeout):
    global STARTING_PROGRAMS

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
            programs = STARTING_PROGRAMS.setdefault(workspace, set())
            programs.add(program)

    if len(STARTING_PROGRAMS) == 0:
        return

    i3.on(Event.WINDOW_NEW, on_new_window)  # type: ignore

    await asyncio.wait_for(i3.main(), timeout=timeout)


def run(workspace_program_config, timeout):
    asyncio.run(main(workspace_program_config, timeout))


def run_command(command: str):
    i3 = Connection()
    i3.command(command)


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
