import os
import socket
import subprocess
from dataclasses import dataclass

import click

hostname = socket.gethostname()


@dataclass
class HostConfig:
    default_workspace: str
    use_sudo: bool


HOST_CONFIGS = {
    "default": HostConfig(default_workspace="~/dev", use_sudo=False),
    "jupiter": HostConfig(default_workspace="~/dev", use_sudo=True),
    "mercury": HostConfig(default_workspace="~/home-dev", use_sudo=False),
}


def get_host_config() -> HostConfig:
    return HOST_CONFIGS.get(hostname, HOST_CONFIGS["default"])


def get_workspace(workspace_folder, config: HostConfig):
    return os.path.expanduser(workspace_folder or config.default_workspace)


def run_command(cmd):
    """Execute a command and stream output."""
    click.echo(f"Detected {hostname=}")
    click.echo(f"{' '.join(cmd)}")
    try:
        result = subprocess.run(cmd, shell=False, check=True)
        return result.returncode
    except subprocess.CalledProcessError as e:
        click.echo(f"Error: Command failed with exit code {e.returncode}", err=True)
        return e.returncode
    except FileNotFoundError:
        click.echo("Error: devcontainer command not found", err=True)
        return 1


@click.group()
def cli():
    """DevContainer management tool with host-specific defaults."""
    pass


@cli.command()
@click.option("-w", "--workspace-folder", default=None, help="Workspace folder path")
@click.option("-r", "--remove-existing-container", is_flag=True, help="Remove existing container")
def up(workspace_folder, remove_existing_container):
    """Start a devcontainer."""
    config = get_host_config()
    workspace = get_workspace(workspace_folder, config)
    cmd = []
    if config.use_sudo:
        cmd.extend(["sudo", "-E"])
    cmd.extend(["devcontainer", "up", "--workspace-folder", workspace])
    if remove_existing_container:
        cmd.append("--remove-existing-container")
    return run_command(cmd)


@cli.command()
@click.option("-w", "--workspace-folder", default=None, help="Workspace folder path")
@click.argument("command", nargs=-1)
def exec(workspace_folder, command):
    """Execute a command in the devcontainer."""
    config = get_host_config()
    workspace = get_workspace(workspace_folder, config)
    cmd = []
    if config.use_sudo:
        cmd.append("sudo")
    cmd.extend(["devcontainer", "exec", "--workspace-folder", workspace])
    if not command:
        command = ("bash",)
    cmd.extend(command)
    return run_command(cmd)
