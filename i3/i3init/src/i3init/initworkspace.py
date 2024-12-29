import asyncio
import logging
import os
import subprocess

from i3ipc import Event, WindowEvent
from i3ipc.aio import Con as AioCon
from i3ipc.aio import Connection as AioConnection

from .entities import Workspace

lock = asyncio.Lock()


WORKSPACES: list[Workspace] = []


async def on_new_window(i3: AioConnection, e: WindowEvent):
    global WORKSPACES

    _ = i3
    window_name = e.container.name
    window_class = e.container.window_class
    window_id: int | None = e.container.window
    if window_id is None:
        raise ValueError("Window id is None")
    window_pid = int(subprocess.Popen(["xwinpid", str(window_id)], stdout=subprocess.PIPE).stdout.read())
    window_pgid = os.getpgid(window_pid)
    # print(f"on_new_window: {window_name=} {window_class=} {window_id=} {window_pid=} {window_pgid=}")

    matched_program = None
    async with lock:
        for w in WORKSPACES:
            for p in w.programs:
                if p.pgid == window_pgid:
                    matched_program = p
    if matched_program is None:
        logging.warning(f"Unexpected window: {window_name=}, {window_class=}, {window_id=}, {window_pid=}")
        return

    workspace = matched_program.workspace

    command = f"move to workspace {workspace.name}"
    print(f"{matched_program.id} {command}")
    await e.container.command(command)
    matched_program.containers.append(e.container)

    async with lock:
        matched_program.done = True
        if all(program.done for program in workspace.programs):
            print(f"All programs in workspace {workspace.name} started")
            for program in workspace.programs:
                if program.window_handling_commands is not None:
                    for command in program.window_handling_commands:
                        print(f"{program.id} {command}")
                        await program.containers[0].command(command)
        if all(workspace.all_programs_done() for workspace in WORKSPACES):
            i3.main_quit()


async def spawn_programs(workspaces: list[Workspace], timeout: float):
    i3 = await AioConnection(auto_reconnect=True).connect()

    global WORKSPACES

    async with lock:
        WORKSPACES.extend(workspaces)

    # We will not touch already existing workspaces containing something
    nonempty_workspaces = get_nonempty_workspaces(await i3.get_tree())

    for workspace in workspaces:
        if workspace.name in nonempty_workspaces:
            print(f"Workspace {workspace.name=} exists")
            for program in workspace.programs:
                print(f"{program.id} skip exec_cmd='{program.exec_cmd}'")
                program.done = True
            continue
        for program in workspace.programs:
            try:
                proc = await asyncio.create_subprocess_shell(
                    program.exec_cmd, process_group=0, stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL
                )
                program.pgid = os.getpgid(proc.pid)
                print(f"{program.id} pid={proc.pid} pgid={program.pgid} exec_cmd='{program.exec_cmd}'")
            except FileNotFoundError as e:
                logging.error(f"{program.exec_cmd}: {e}")
                continue

    async with lock:
        if all(workspace.all_programs_done() for workspace in workspaces):
            return

    i3.on(Event.WINDOW_NEW, on_new_window)  # type: ignore

    await asyncio.wait_for(i3.main(), timeout=timeout)


def run(workspaces: list[Workspace], *, timeout: float):
    asyncio.get_event_loop().run_until_complete(spawn_programs(workspaces, timeout))


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
