import os
import socket
import subprocess
from dataclasses import dataclass

import click


@dataclass
class Config:
    default_workspace: str
    use_sudo: bool


hostname = socket.gethostname()
click.echo(f"Detected {hostname=}")
DEFAULT_CONFIG = Config(default_workspace="~/dev", use_sudo=False)
HOST_CONFIGS = {
    "jupiter": Config(default_workspace="~/dev", use_sudo=True),
    "mercury": Config(default_workspace="~/home-dev", use_sudo=False),
}
g_config = HOST_CONFIGS.get(hostname, DEFAULT_CONFIG)
g_workspace = None


def run_command(cmd, capture_output=False):
    click.echo(f"$ {' '.join(cmd)}")
    try:
        if capture_output:
            result = subprocess.run(cmd, shell=False, capture_output=True, text=True, check=True)
        else:
            result = subprocess.run(cmd, shell=False, check=True)
        return result
    except subprocess.CalledProcessError as e:
        click.echo(f"Error: Command failed with exit code {e.returncode}", err=True)
        return e


@click.group(context_settings={"help_option_names": ["-h", "--help"]})
@click.option("-w", "--workspace-folder", default=None, help="Workspace folder path")
def cli(workspace_folder):
    """DevContainer management tool with host-specific defaults."""
    global g_workspace
    g_workspace = os.path.abspath(os.path.expanduser(workspace_folder or g_config.default_workspace))


@cli.command()
@click.option("-r", "--remove-existing-container", is_flag=True, help="Remove existing container")
@click.option("--no-cache", is_flag=True, help="Force Docker to skip layer cache")
def up(remove_existing_container, no_cache):
    """Start a devcontainer."""
    cmd = []
    if g_config.use_sudo:
        cmd.extend(["sudo", "-E"])
    if no_cache:
        cmd0 = cmd.copy()
        cmd0.extend(["devcontainer", "build", "--workspace-folder", g_workspace, "--no-cache"])
        cmd.extend(["devcontainer", "up", "--workspace-folder", g_workspace])
        run_command(cmd0)
    else:
        cmd.extend(["devcontainer", "up", "--workspace-folder", g_workspace])
        if remove_existing_container:
            cmd.append("--remove-existing-container")
    run_command(cmd)


@cli.command()
def down():
    """Stop a devcontainer."""
    click.echo(f"Looking for container with workspace: {g_workspace}")
    cmd_list_containers = []
    if g_config.use_sudo:
        cmd_list_containers.append("sudo")
    cmd_list_containers.extend(["docker", "ps", "-q", "--filter", f"label=devcontainer.local_folder={g_workspace}"])
    result = run_command(cmd_list_containers, capture_output=True)
    container_ids = result.stdout.strip().split("\n")
    container_ids = [cid for cid in container_ids if cid]  # Remove empty strings

    if container_ids:
        click.echo(f"Found {len(container_ids)} container(s): {', '.join(container_ids)}")
        for container_id in container_ids:
            cmd_stop = []
            if g_config.use_sudo:
                cmd_stop.append("sudo")
            cmd_stop.extend(["docker", "stop", container_id])
            run_command(cmd_stop)
    else:
        click.echo("No running devcontainer found for this workspace")


@cli.command()
@click.argument("command", nargs=-1)
def exec(command):
    """Execute a command in the devcontainer."""
    cmd = []
    if g_config.use_sudo:
        cmd.append("sudo")
    cmd.extend(["devcontainer", "exec", "--workspace-folder", g_workspace])
    if not command:
        command = ("bash",)
    cmd.extend(command)
    run_command(cmd)


if __name__ == "__main__":
    cli()
