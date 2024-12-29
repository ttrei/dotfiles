import asyncio
from dataclasses import dataclass, field
from typing import Optional
from uuid import uuid4

lock = asyncio.Lock()


@dataclass(kw_only=True)
class Program:
    exec_cmd: str
    id: str = field(default_factory=lambda: str(uuid4()))

    window_handling_commands: list[str] | None = None
    workspace: Optional["Workspace"] = None
    containers: list = field(default_factory=list)
    pgid: int | None = None
    # How long to wait for the program to spawn extra windows
    # TODO: how to stop waiting when the timeout expires?
    timeout_extra_windows: float | None = None
    done: bool = False


@dataclass
class Workspace:
    name: str
    programs: list[Program] = field(default_factory=list)

    def with_programs(self, *programs: Program):
        for program in programs:
            program.workspace = self
        self.programs.extend(programs)
        return self

    def all_programs_done(self):
        return all(program.done for program in self.programs)
