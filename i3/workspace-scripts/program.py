from typing import Dict, List


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
