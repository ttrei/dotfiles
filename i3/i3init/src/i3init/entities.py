import time
from dataclasses import dataclass, field
from typing import Optional
from uuid import uuid4


@dataclass
class Program:
    cmd: str
    workspace: Optional["Workspace"] = None
    # for tracing in logs
    id: str = field(default_factory=lambda: str(uuid4()))
    # process group id - for matching windows to programs
    pgid: int | None = None
    # Commands to execute when all programs of the workspace have started
    commands: list[str] = field(default_factory=list)
    # i3 containers containing the matched windows
    containers: list = field(default_factory=list)
    # How long to wait for the program to create extra windows (seconds)
    timeout_extra_windows: float | None = None
    timeout_extra_windows_expiry: float | None = None
    # Use if it's known how many windows the program will spawn
    expected_number_of_windows: int | None = None
    done: bool = False

    def __post_init__(self):
        if self.timeout_extra_windows is not None and self.expected_number_of_windows is not None:
            raise ValueError("timeout_extra_windows and expected_number_of_windows are mutually exclusive")
        if self.timeout_extra_windows is not None:
            self.timeout_extra_windows_expiry = time.monotonic() + self.timeout_extra_windows
        elif self.expected_number_of_windows is None:
            self.expected_number_of_windows = 1

    def check_done(self):
        if self.expected_number_of_windows is not None:
            if len(self.containers) >= self.expected_number_of_windows:
                self.done = True
        elif self.timeout_extra_windows_expiry is not None:
            if time.monotonic() > self.timeout_extra_windows_expiry:
                self.done = True


@dataclass
class Workspace:
    name: str
    programs: list[Program] = field(default_factory=list)

    def with_programs(self, *programs: Program):
        for program in programs:
            program.workspace = self
        self.programs.extend(programs)
        return self

    def done(self):
        return all(program.done for program in self.programs)
