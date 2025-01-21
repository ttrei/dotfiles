import argparse
import importlib.util
import sys
from pathlib import Path

from rofi import Rofi

import i3init


def import_python_module(path: Path):
    spec = importlib.util.spec_from_file_location("i3config", path)
    module = importlib.util.module_from_spec(spec)
    sys.modules["i3config"] = module
    spec.loader.exec_module(module)
    return module


def run(config):
    if not hasattr(config, "I3SCHEMAS"):
        print("Error: the schema script must define I3SCHEMAS variable")
        return

    i3schemas = config.I3SCHEMAS
    timeout = getattr(config, "TIMEOUT", 5)

    rofi = Rofi()
    options = list(i3schemas.keys())
    index, key = rofi.select("Select workspace configuration", options)
    if key == -1:  # Selection canceled
        return
    config_key = options[index]
    workspaces = i3schemas[config_key]

    # i3init.run_command(f"workspace {workspace}")
    i3init.run(workspaces, timeout=timeout)


def main_cli():
    parser = argparse.ArgumentParser(description="i3init workspace selector")
    parser.add_argument("config", type=str, help="Path to Python config file")
    args = parser.parse_args()

    config = import_python_module(Path(args.config))
    run(config)
