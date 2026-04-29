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
DEFAULT_CONFIG = Config(default_workspace="~/dev")
HOST_CONFIGS = {
    "jupiter": Config(default_workspace="~/dev"),
    "jupiter-work": Config(default_workspace="~/dev"),
    "mercury": Config(default_workspace="~/dev"),
}

CONFIG = HOST_CONFIGS.get(hostname, DEFAULT_CONFIG)
CONTAINER_WORKSPACE = Path("/workspace")


def get_workspace(ctx: click.Context) -> Path:
    workspace = ctx.obj.get("workspace") if isinstance(ctx.obj, dict) else None
    if not isinstance(workspace, Path):
        raise click.ClickException("Workspace is not configured")
    return workspace


def run_command(cmd, capture_output=False):
    click.echo(f"+ {shlex.join(str(part) for part in cmd)}")
    try:
        return subprocess.run(cmd, shell=False, capture_output=capture_output, text=True, check=True)
    except subprocess.CalledProcessError as e:
        message = f"Command failed with exit code {e.returncode}: {shlex.join(str(part) for part in cmd)}"
        stderr = (e.stderr or "").strip()
        if stderr:
            message = f"{message}\n{stderr}"
        raise click.ClickException(message) from e


def get_running_container_ids(workspace: Path) -> list[str]:
    result = run_command(
        ["docker", "ps", "-q", "--filter", f"label=devcontainer.local_folder={workspace}"],
        capture_output=True,
    )
    return [cid for cid in result.stdout.splitlines() if cid]


def deduplicate_paths(paths) -> list[Path]:
    seen = set()
    unique_paths = []
    for path in paths:
        path = Path(path).expanduser()
        if not path.is_absolute():
            path = Path.cwd() / path
        path = path.resolve(strict=False)
        if path not in seen:
            seen.add(path)
            unique_paths.append(path)
    return unique_paths


def collect_mount_paths(workspace: Path, extra_mounts, include_workspace: bool) -> list[Path]:
    mount_paths = []
    if include_workspace:
        mount_paths.append(workspace)
    mount_paths.append(Path.home() / ".pi")
    mount_paths.extend(Path(path) for path in extra_mounts)
    return deduplicate_paths(mount_paths)


def resolve_mounts(mount_paths):
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
@click.pass_context
def cli(ctx, workspace_folder):
    """DevContainer management tool with host-specific defaults."""
    click.echo(f"Detected {hostname=}", err=True)
    obj = ctx.ensure_object(dict)
    obj["workspace"] = Path(workspace_folder or CONFIG.default_workspace).expanduser().resolve(strict=False)


@cli.command()
@click.option("-r", "--remove-existing-container", is_flag=True, help="Remove existing container")
@click.option("--no-cache", is_flag=True, help="Force Docker to skip layer cache")
@click.option(
    "-m", "--mount", "extra_mounts", multiple=True, help="Additional path to mount (relative to cwd, repeatable)"
)
@click.option("--no-defaults", is_flag=True, help="Skip mounting the workspace automatically")
@click.pass_context
def up(ctx, remove_existing_container, no_cache, extra_mounts, no_defaults):
    """Start a devcontainer with selective mounts."""
    workspace = get_workspace(ctx)

    # Check if a container is already running
    if not remove_existing_container and not no_cache:
        container_ids = get_running_container_ids(workspace)
        if container_ids:
            click.echo(f"Error: container already running ({container_ids[0][:12]}). Use -r to recreate.", err=True)
            raise SystemExit(1)

    mount_paths = collect_mount_paths(workspace, extra_mounts, include_workspace=not no_defaults)
    mount_strings = resolve_mounts(mount_paths)

    if mount_strings:
        click.echo("Mounts:")
        for m in mount_strings:
            click.echo(f"  {m}")
    else:
        click.echo("Warning: no mounts configured, container will have no workspace files")

    # Generate override config: load the base devcontainer.json and patch
    # the mounts array, since --override-config replaces the entire config.
    mount_strings.append("source=devcontainer-bashhistory,target=/commandhistory,type=volume")

    base_config_path = workspace / ".devcontainer" / "devcontainer.json"
    with base_config_path.open() as f:
        override = json.load(f)
    override["mounts"] = mount_strings
    override_file = tempfile.NamedTemporaryFile(mode="w", suffix=".json", prefix="devrun-mounts-", delete=False)
    try:
        json.dump(override, override_file)
        override_file.close()

        if no_cache:
            cmd0 = ["devcontainer", "build", "--workspace-folder", str(workspace), "--no-cache"]
            run_command(cmd0)

        cmd = ["devcontainer", "up", "--workspace-folder", str(workspace), "--override-config", override_file.name]
        if no_cache or remove_existing_container:
            cmd.append("--remove-existing-container")
        run_command(cmd)
    finally:
        Path(override_file.name).unlink()


@cli.command()
@click.option("-d", "--depth", default=2, show_default=True, type=click.IntRange(min=0))
@click.pass_context
def pick(ctx, depth):
    """Interactively pick mount paths and print a devrun up command."""
    workspace = get_workspace(ctx)
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

    cmd = ["devrun", "-w", str(workspace), "up"]
    for path in selected:
        abs_path = (search_root / path).resolve(strict=False)
        cmd.extend(["-m", str(abs_path)])
    click.echo(shlex.join(cmd))


@cli.command()
@click.pass_context
def down(ctx):
    """Stop a devcontainer."""
    workspace = get_workspace(ctx)
    click.echo(f"Looking for container with workspace: {workspace}")
    container_ids = get_running_container_ids(workspace)

    if container_ids:
        click.echo(f"Found {len(container_ids)} container(s): {', '.join(container_ids)}")
        for container_id in container_ids:
            cmd_stop = ["docker", "stop", container_id]
            run_command(cmd_stop)
    else:
        click.echo("No running devcontainer found for this workspace")


@cli.command()
@click.pass_context
def status(ctx):
    """Show devcontainer status."""
    workspace = get_workspace(ctx)
    click.echo(f"Workspace: {workspace}")

    container_ids = get_running_container_ids(workspace)

    if not container_ids:
        click.echo("Container: not running")
        return

    container_id = container_ids[0]

    result = run_command(["docker", "inspect", container_id], capture_output=True)
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


@cli.command("exec")
@click.argument("command", nargs=-1)
@click.pass_context
def exec_cmd(ctx, command):
    """Execute a command in the devcontainer."""
    workspace = get_workspace(ctx)
    cmd = ["devcontainer", "exec", "--workspace-folder", str(workspace)]
    if not command:
        command = ("bash",)
    cmd.extend(command)
    run_command(cmd)


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


if __name__ == "__main__":
    cli()
