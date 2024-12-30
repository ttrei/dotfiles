import asyncio
import logging
import os
import subprocess

from i3ipc import Event, WindowEvent
from i3ipc.aio import Con as AioCon
from i3ipc.aio import Connection as AioConnection

from .entities import Program, Workspace

lock = asyncio.Lock()


PROGRAMS: list[Program] = []


async def on_new_window(i3: AioConnection, e: WindowEvent):
    _ = i3
    window_name = e.container.name
    window_class = e.container.window_class
    window_id: int | None = e.container.window
    if window_id is None:
        raise ValueError(f"Window id is None for {window_name=} {window_class=}")
    window_pid = int(subprocess.Popen(["xwinpid", str(window_id)], stdout=subprocess.PIPE).stdout.read())
    window_pgid = os.getpgid(window_pid)
    print(
        f"on_new_window: {e.container.id=} {hex(e.container.id)=} {window_id=} {hex(window_id)=} {window_name=} {window_class=} {window_pid=} {window_pgid=}"
    )

    async with lock:
        matched_program = None
        for program in PROGRAMS:
            if program.pgid == window_pgid:
                matched_program = program
        if matched_program is None:
            logging.warning(f"Unexpected window: {window_name=} {window_class=} {window_id=} {window_pid=}")
            return
        print(f"{matched_program.id} matched {window_name=} {window_class=} {window_id=} {window_pid=} {window_pgid=}")

        workspace = matched_program.workspace

        command = f"move to workspace {workspace.name}"
        print(f"{matched_program.id} {e.container.id=} {hex(e.container.id)=} {window_id=} {hex(window_id)=} {command}")
        # await asyncio.sleep(0.1) # Tried to work around firefox window creation bug
        await e.container.command(command)
        matched_program.containers.append(e.container)


async def spawn_programs(workspaces: list[Workspace], timeout: float, debug: bool):
    i3 = await AioConnection(auto_reconnect=True).connect()
    i3.on(Event.WINDOW_NEW, on_new_window)  # type: ignore
    await i3.command(f"workspace {workspaces[0].name}")

    future_check_done = asyncio.ensure_future(check_done(workspaces, i3))

    global PROGRAMS
    async with lock:
        for workspace in workspaces:
            PROGRAMS.extend(workspace.programs)

    nonempty_workspaces = get_nonempty_workspaces(await i3.get_tree())
    for workspace in workspaces:
        if workspace.name in nonempty_workspaces:
            print(f"Workspace {workspace.name=} exists and is not empty")
            async with lock:
                for program in workspace.programs:
                    print(f"{program.id} skip cmd='{program.cmd}'")
                    program.done = True
            continue
        for program in workspace.programs:
            async with lock:
                try:
                    if debug:
                        proc = await asyncio.create_subprocess_shell(program.cmd, process_group=0)
                    else:
                        proc = await asyncio.create_subprocess_shell(
                            program.cmd, process_group=0, stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL
                        )
                    program.pgid = os.getpgid(proc.pid)
                    print(f"{program.id} created pid={proc.pid} pgid={program.pgid} cmd='{program.cmd}'")
                except FileNotFoundError as e:
                    logging.error(f"{program.cmd}: {e}")
                    continue

    async with lock:
        if all(workspace.programs_done() for workspace in workspaces):
            future_check_done.cancel()
            return

    await asyncio.wait_for(i3.main(), timeout=timeout)
    future_check_done.cancel()


async def check_done(workspaces: list[Workspace], i3: AioConnection):
    while True:
        await asyncio.sleep(0.1)
        async with lock:
            for program in PROGRAMS:
                program.check_done()
            for workspace in workspaces:
                if not workspace.programs_done() or workspace.commands_done:
                    continue
                print(f"All programs in workspace {workspace.name} started")
                for program in workspace.programs:
                    for command in program.commands:
                        if len(program.containers) == 0:
                            continue
                        print(f"{program.id} {command}")
                        await program.containers[0].command(command)
                workspace.commands_done = True
            if all(workspace.programs_done() and workspace.commands_done for workspace in workspaces):
                print("All programs done, exiting")
                i3.main_quit()
                return


def run(workspaces: list[Workspace], *, timeout: float, debug: bool = False):
    # Using asyncio.run() or asyncio.new_event_loop().run_until_complete() prevents firefox from starting ("Exiting due to channel error.")
    # Not sure what's going on.
    # asyncio.get_event_loop() should log deprecation warning if event loop doesn't exist.
    # But i don't get any warning, so probably i3ipc has created the loop already?
    asyncio.get_event_loop().run_until_complete(spawn_programs(workspaces, timeout, debug))


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
