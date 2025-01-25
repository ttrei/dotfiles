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


def choose_schema(schemas):
    rofi = Rofi()
    options = list(schemas)
    index, key = rofi.select("Select workspace configuration", options)
    if key == -1:  # Selection canceled
        return
    return options[index]


def run(config, schema_name=None):
    if not hasattr(config, "I3SCHEMAS"):
        print("Error: the schema script must define I3SCHEMAS variable")
        return

    i3schemas = config.I3SCHEMAS
    timeout = getattr(config, "TIMEOUT", 5)

    if schema_name is None:
        schema_name = choose_schema(i3schemas.keys())
    workspaces = i3schemas[schema_name]

    i3init.run(workspaces, timeout=timeout)


def main_cli():
    parser = argparse.ArgumentParser(description="Select and run i3init schema")
    parser.add_argument("config", type=str, help="Path to schemas config file")
    parser.add_argument("schema", type=str, nargs="?", help="Schema name (optional)")
    args = parser.parse_args()

    config = import_python_module(Path(args.config))
    run(config, args.schema)
