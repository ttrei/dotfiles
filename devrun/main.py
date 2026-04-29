import json
import shlex
import shutil
import socket
import subprocess
import tempfile
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

import click


@dataclass
class Config:
    default_workspace: str


hostname = socket.gethostname()
click.echo(f"Detected {hostname=}", err=True)
DEFAULT_CONFIG = Config(default_workspace="~/dev")
HOST_CONFIGS = {
    "jupiter": Config(default_workspace="~/dev"),
    "jupiter-work": Config(default_workspace="~/dev"),
    "mercury": Config(default_workspace="~/dev"),
}

CONFIG = HOST_CONFIGS.get(hostname, DEFAULT_CONFIG)
HOST_WORKSPACE: Path | None = None

CONTAINER_WORKSPACE = Path("/workspace")


def run_command(cmd, capture_output=False):
    click.echo(f"+ {' '.join(cmd)}")
    try:
        if capture_output:
            result = subprocess.run(cmd, shell=False, capture_output=True, text=True, check=True)
        else:
            result = subprocess.run(cmd, shell=False, check=True)
        return result
    except subprocess.CalledProcessError as e:
        click.echo(f"Error: Command failed with exit code {e.returncode}", err=True)
        return e


def resolve_mounts(workspace, mount_paths):
    mounts = []
    for path in mount_paths:
        host_path = Path(path).expanduser()
        if not host_path.is_absolute():
            host_path = Path.cwd() / host_path
        host_path = host_path.resolve(strict=False)
        if not host_path.exists():
            click.echo(f"Warning: mount path does not exist: {host_path}", err=True)
            continue
        mounts.append(build_mount_string(host_path))
    return mounts


def build_mount_string(host_path: Path):
    host_path = host_path.expanduser().resolve(strict=False)
    home = Path.home().resolve()
    if not host_path.is_absolute():
        raise ValueError(f"{host_path} is not absolute")
    try:
        container_path = host_path.relative_to(home)
    except ValueError:
        # not inside home; keep the absolute path under /workspace without
        # allowing an absolute Path to discard CONTAINER_WORKSPACE.
        container_path = Path(*host_path.parts[1:])
    target_path = CONTAINER_WORKSPACE / container_path
    return f"source={host_path},target={target_path.as_posix()},type=bind"


def fd_paths(search_root, depth, path_type):
    """Return fd results relative to search_root."""
    cmd = [
        "fd",
        "--hidden",
        "--follow",
        "--exclude",
        ".git",
        "--exclude",
        "node_modules",
        "--exclude",
        ".venv",
        "--exclude",
        "__pycache__",
        "--max-depth",
        str(depth),
        "--type",
        path_type,
        ".",
    ]
    result = subprocess.run(cmd, cwd=search_root, capture_output=True, text=True)
    if result.returncode != 0:
        raise click.ClickException(result.stderr.strip() or f"fd failed with exit code {result.returncode}")
    return [line for line in result.stdout.splitlines() if line]


@click.group(context_settings={"help_option_names": ["-h", "--help"]})
@click.option("-w", "--workspace-folder", default=None, help="Workspace folder path")
def cli(workspace_folder):
    """DevContainer management tool with host-specific defaults."""
    global HOST_WORKSPACE
    HOST_WORKSPACE = Path(workspace_folder or CONFIG.default_workspace).expanduser().resolve(strict=False)


@cli.command()
@click.option("-r", "--remove-existing-container", is_flag=True, help="Remove existing container")
@click.option("--no-cache", is_flag=True, help="Force Docker to skip layer cache")
@click.option(
    "-m", "--mount", "extra_mounts", multiple=True, help="Additional path to mount (relative to cwd, repeatable)"
)
@click.option("--no-defaults", is_flag=True, help="Skip default mounts from .devcontainer/mounts.list")
def up(remove_existing_container, no_cache, extra_mounts, no_defaults):
    """Start a devcontainer with selective mounts."""
    # Check if a container is already running
    if not remove_existing_container and not no_cache:
        result = run_command(
            ["docker", "ps", "-q", "--filter", f"label=devcontainer.local_folder={HOST_WORKSPACE}"],
            capture_output=True,
        )
        if not isinstance(result, subprocess.CalledProcessError):
            container_ids = [cid for cid in result.stdout.strip().split("\n") if cid]
            if container_ids:
                click.echo(f"Error: container already running ({container_ids[0][:12]}). Use -r to recreate.", err=True)
                raise SystemExit(1)

    # Collect mount paths
    mount_paths = []
    if not no_defaults:
        mount_paths.append(HOST_WORKSPACE)
    mount_paths.append(Path.home() / ".pi")
    mount_paths.extend(Path(path) for path in extra_mounts)

    # Deduplicate while preserving order
    seen = set()
    unique_paths = []
    for p in mount_paths:
        p = p.expanduser().resolve(strict=False)
        if p not in seen:
            seen.add(p)
            unique_paths.append(p)

    mount_strings = resolve_mounts(HOST_WORKSPACE, unique_paths)

    if mount_strings:
        click.echo("Mounts:")
        for m in mount_strings:
            click.echo(f"  {m}")
    else:
        click.echo("Warning: no mounts configured, container will have no workspace files")

    # Generate override config: load the base devcontainer.json and patch
    # the mounts array, since --override-config replaces the entire config.
    mount_strings.append("source=devcontainer-bashhistory,target=/commandhistory,type=volume")

    base_config_path = HOST_WORKSPACE / ".devcontainer" / "devcontainer.json"
    with base_config_path.open() as f:
        override = json.load(f)
    override["mounts"] = mount_strings
    override_file = tempfile.NamedTemporaryFile(mode="w", suffix=".json", prefix="devrun-mounts-", delete=False)
    try:
        json.dump(override, override_file)
        override_file.close()

        if no_cache:
            cmd0 = ["devcontainer", "build", "--workspace-folder", str(HOST_WORKSPACE), "--no-cache"]
            run_command(cmd0)

        cmd = ["devcontainer", "up", "--workspace-folder", str(HOST_WORKSPACE), "--override-config", override_file.name]
        if no_cache or remove_existing_container:
            cmd.append("--remove-existing-container")
        run_command(cmd)
    finally:
        Path(override_file.name).unlink()


@cli.command()
@click.option("-d", "--depth", default=2, show_default=True, type=click.IntRange(min=0))
def pick(depth):
    """Interactively pick mount paths and print a devrun up command."""
    missing = [name for name in ("fd", "fzf") if shutil.which(name) is None]
    if missing:
        raise click.ClickException(f"Missing required commands: {', '.join(missing)}")

    search_root = Path.cwd()
    dir_paths = ["."] + fd_paths(search_root, depth, "d")
    file_paths = fd_paths(search_root, depth, "f")
    candidates = dir_paths + file_paths
    if not candidates:
        raise click.ClickException(f"No files or directories found under {search_root}")

    result = subprocess.run(
        ["fzf", "--multi", "--prompt", "mount> ", "--header", f"select mount paths under {search_root}"],
        input="\n".join(candidates) + "\n",
        capture_output=True,
        text=True,
    )
    if result.returncode in (1, 130):
        raise SystemExit(result.returncode)
    if result.returncode != 0:
        raise click.ClickException(result.stderr.strip() or f"fzf failed with exit code {result.returncode}")

    selected = [line for line in result.stdout.splitlines() if line]
    if not selected:
        raise SystemExit(1)

    cmd = ["devrun", "-w", str(HOST_WORKSPACE), "up"]
    for path in selected:
        abs_path = (search_root / path).resolve(strict=False)
        cmd.extend(["-m", str(abs_path)])
    click.echo(shlex.join(cmd))


@cli.command()
def down():
    """Stop a devcontainer."""
    click.echo(f"Looking for container with workspace: {HOST_WORKSPACE}")
    cmd_list_containers = ["docker", "ps", "-q", "--filter", f"label=devcontainer.local_folder={HOST_WORKSPACE}"]
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
    click.echo(f"Workspace: {HOST_WORKSPACE}")

    result = run_command(
        ["docker", "ps", "-q", "--filter", f"label=devcontainer.local_folder={HOST_WORKSPACE}"],
        capture_output=True,
    )
    if isinstance(result, subprocess.CalledProcessError):
        click.echo("Container: error querying docker")
        return
    container_ids = [cid for cid in result.stdout.strip().split("\n") if cid]

    if not container_ids:
        click.echo("Container: not running")
        return

    container_id = container_ids[0]

    result = run_command(["docker", "inspect", container_id], capture_output=True)
    if isinstance(result, subprocess.CalledProcessError):
        click.echo("Container: error inspecting container")
        return
    info = json.loads(result.stdout)[0]
    state = info["State"]
    status_str = state.get("Status", "unknown")
    started_at = state.get("StartedAt", "")
    image = info["Config"].get("Image", "unknown")

    ago = relative_time(started_at) if started_at else ""

    click.echo(f"Container: {container_id[:12]} ({status_str}, started {ago})")
    click.echo(f"Image:     {image}")

    mounts = info.get("Mounts", [])
    if mounts:
        click.echo("Mounts:")
        for m in sorted(mounts, key=lambda m: m.get("Source") or m.get("Name", "")):
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
    cmd = ["devcontainer", "exec", "--workspace-folder", str(HOST_WORKSPACE)]
    if not command:
        command = ("bash",)
    cmd.extend(command)
    run_command(cmd)


if __name__ == "__main__":
    cli()


def relative_time(iso_timestamp):
    """Convert an ISO timestamp to a human-readable relative time string."""
    try:
        dt = datetime.fromisoformat(iso_timestamp.replace("Z", "+00:00"))
        secs = int((datetime.now(timezone.utc) - dt).total_seconds())
        if secs < 60:
            return f"{secs}s ago"
        elif secs < 3600:
            return f"{secs // 60}m ago"
        elif secs < 86400:
            h, m = secs // 3600, (secs % 3600) // 60
            return f"{h}h{m}m ago" if m else f"{h}h ago"
        else:
            d, h = secs // 86400, (secs % 86400) // 3600
            return f"{d}d{h}h ago" if h else f"{d}d ago"
    except (ValueError, TypeError):
        return iso_timestamp
