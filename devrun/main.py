import json
import os
import socket
import subprocess
import tempfile
from dataclasses import dataclass

import click


@dataclass
class Config:
    default_workspace: str


hostname = socket.gethostname()
click.echo(f"Detected {hostname=}")
DEFAULT_CONFIG = Config(default_workspace="~/dev")
HOST_CONFIGS = {
    "jupiter": Config(default_workspace="~/dev"),
    "jupiter-work": Config(default_workspace="~/dev"),
    "mercury": Config(default_workspace="~/dev"),
}
g_config = HOST_CONFIGS.get(hostname, DEFAULT_CONFIG)
g_workspace = None

MOUNTS_LIST = ".devcontainer/mounts.list"
CONTAINER_WORKSPACE = "/workspace"


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


def load_default_mounts(workspace):
    """Load mount paths from .devcontainer/mounts.list."""
    mounts_file = os.path.join(workspace, MOUNTS_LIST)
    if not os.path.exists(mounts_file):
        return []
    paths = []
    with open(mounts_file) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#"):
                paths.append(line)
    return paths


def resolve_mounts(workspace, mount_paths):
    """Resolve mount paths to devcontainer mount strings.

    Relative paths are resolved against the workspace and mounted at the
    same relative location under /workspace.  Absolute paths (or paths
    that escape the workspace via '..') are mounted under /workspace
    using their basename.
    """
    mounts = []
    for path in mount_paths:
        host_path = os.path.abspath(os.path.join(workspace, path))
        if not os.path.exists(host_path):
            click.echo(f"Warning: mount path does not exist: {host_path}", err=True)
            continue
        # Determine container target: keep the relative structure for paths
        # inside the workspace, use basename for everything else.
        try:
            rel = os.path.relpath(host_path, workspace)
        except ValueError:
            rel = None
        if rel and not rel.startswith(".."):
            container_path = f"{CONTAINER_WORKSPACE}/{rel}"
        else:
            container_path = f"{CONTAINER_WORKSPACE}/{os.path.basename(host_path)}"
        mount_str = f"source={host_path},target={container_path},type=bind"
        mounts.append(mount_str)
    return mounts


@click.group(context_settings={"help_option_names": ["-h", "--help"]})
@click.option("-w", "--workspace-folder", default=None, help="Workspace folder path")
def cli(workspace_folder):
    """DevContainer management tool with host-specific defaults."""
    global g_workspace
    g_workspace = os.path.abspath(os.path.expanduser(workspace_folder or g_config.default_workspace))


@cli.command()
@click.option("-r", "--remove-existing-container", is_flag=True, help="Remove existing container")
@click.option("--no-cache", is_flag=True, help="Force Docker to skip layer cache")
@click.option(
    "-m", "--mount", "extra_mounts", multiple=True, help="Additional path to mount (relative to workspace, repeatable)"
)
@click.option("--no-defaults", is_flag=True, help="Skip default mounts from .devcontainer/mounts.list")
def up(remove_existing_container, no_cache, extra_mounts, no_defaults):
    """Start a devcontainer with selective mounts."""
    # Collect mount paths
    mount_paths = []
    if not no_defaults:
        mount_paths.extend(load_default_mounts(g_workspace))
    mount_paths.extend(extra_mounts)

    # Deduplicate while preserving order
    seen = set()
    unique_paths = []
    for p in mount_paths:
        if p not in seen:
            seen.add(p)
            unique_paths.append(p)

    mount_strings = resolve_mounts(g_workspace, unique_paths)

    if mount_strings:
        click.echo("Mounts:")
        for m in mount_strings:
            click.echo(f"  {m}")
    else:
        click.echo("Warning: no mounts configured, container will have no workspace files")

    # Generate override config: load the base devcontainer.json and patch
    # the mounts array, since --override-config replaces the entire config.
    mount_strings.append("source=devcontainer-bashhistory,target=/commandhistory,type=volume")
    base_config_path = os.path.join(g_workspace, ".devcontainer", "devcontainer.json")
    with open(base_config_path) as f:
        override = json.load(f)
    override["mounts"] = mount_strings
    override_file = tempfile.NamedTemporaryFile(mode="w", suffix=".json", prefix="devrun-mounts-", delete=False)
    try:
        json.dump(override, override_file)
        override_file.close()

        if no_cache:
            cmd0 = ["devcontainer", "build", "--workspace-folder", g_workspace, "--no-cache"]
            run_command(cmd0)

        cmd = ["devcontainer", "up", "--workspace-folder", g_workspace, "--override-config", override_file.name]
        if no_cache or remove_existing_container:
            cmd.append("--remove-existing-container")
        run_command(cmd)
    finally:
        os.unlink(override_file.name)


@cli.command()
def down():
    """Stop a devcontainer."""
    click.echo(f"Looking for container with workspace: {g_workspace}")
    cmd_list_containers = ["docker", "ps", "-q", "--filter", f"label=devcontainer.local_folder={g_workspace}"]
    result = run_command(cmd_list_containers, capture_output=True)
    container_ids = result.stdout.strip().split("\n")
    container_ids = [cid for cid in container_ids if cid]  # Remove empty strings

    if container_ids:
        click.echo(f"Found {len(container_ids)} container(s): {', '.join(container_ids)}")
        for container_id in container_ids:
            cmd_stop = ["docker", "stop", container_id]
            run_command(cmd_stop)
    else:
        click.echo("No running devcontainer found for this workspace")


@cli.command()
def status():
    """Show devcontainer status."""
    click.echo(f"Workspace: {g_workspace}")

    # Find container
    result = subprocess.run(
        ["docker", "ps", "-q", "--filter", f"label=devcontainer.local_folder={g_workspace}"],
        capture_output=True,
        text=True,
    )
    container_ids = [cid for cid in result.stdout.strip().split("\n") if cid]

    if not container_ids:
        click.echo("Container: not running")
        return

    container_id = container_ids[0]

    # Inspect container
    result = subprocess.run(
        ["docker", "inspect", container_id],
        capture_output=True,
        text=True,
    )
    info = json.loads(result.stdout)[0]
    state = info["State"]
    status_str = state.get("Status", "unknown")
    started_at = state.get("StartedAt", "")
    image = info["Config"].get("Image", "unknown")

    click.echo(f"Container: {container_id[:12]} ({status_str}, started {started_at})")
    click.echo(f"Image:     {image}")

    # Show mounts
    mounts = info.get("Mounts", [])
    if mounts:
        click.echo("\nMounts:")
        for m in mounts:
            src = m.get("Source") or m.get("Name", "")
            dst = m["Destination"]
            mtype = m["Type"]
            rw = "rw" if m.get("RW", True) else "ro"
            if mtype == "volume":
                click.echo(f"  {src:<40s} → {dst:<30s} ({mtype})")
            else:
                click.echo(f"  {src:<40s} → {dst:<30s} ({mtype}, {rw})")


@cli.command()
@click.argument("command", nargs=-1)
def exec(command):
    """Execute a command in the devcontainer."""
    cmd = ["devcontainer", "exec", "--workspace-folder", g_workspace]
    if not command:
        command = ("bash",)
    cmd.extend(command)
    run_command(cmd)


if __name__ == "__main__":
    cli()
