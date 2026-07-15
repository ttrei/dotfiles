#!/usr/bin/env python3

import os
import shlex
import shutil
import subprocess
import sys
from collections.abc import Sequence


def fail(message: str, exit_code: int = 1) -> None:
    print(message, file=sys.stderr)
    raise SystemExit(exit_code)


def git_output(*args: str) -> list[str]:
    result = subprocess.run(
        ["git", *args],
        stdout=subprocess.PIPE,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise SystemExit(result.returncode)
    return result.stdout.splitlines()


def select_with_fzf(entries: Sequence[str], *args: str) -> str:
    result = subprocess.run(
        ["fzf", "--layout=reverse", "--height=40%", *args],
        input="\n".join(entries) + "\n",
        stdout=subprocess.PIPE,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        fail("No branch selected", result.returncode)
    return result.stdout.rstrip("\n")


def run_and_print(command: Sequence[str]) -> None:
    print(shlex.join(command), flush=True)
    raise SystemExit(subprocess.run(command, check=False).returncode)


def main() -> None:
    if shutil.which("fzf") is None:
        fail("Error: fzf is not installed")

    if len(sys.argv) > 2 or (len(sys.argv) == 2 and sys.argv[1] != "--local"):
        fail(f"Usage: {os.path.basename(sys.argv[0])} [--local]")

    local_branches = git_output("for-each-ref", "--format=%(refname:lstrip=2)", "refs/heads/")
    remote_branch_details = git_output(
        "for-each-ref",
        "--format=%(refname:lstrip=3)%09%(refname:lstrip=2)",
        "refs/remotes/",
    )

    remotes_by_branch: dict[str, list[str]] = {}
    for detail in remote_branch_details:
        branch, full_name = detail.split("\t", 1)
        if branch == "HEAD":
            continue
        remote = full_name[: -(len(branch) + 1)]
        remotes_by_branch.setdefault(branch, []).append(remote)

    remote_branches = list(remotes_by_branch)
    if len(sys.argv) == 1:
        branches = local_branches + remote_branches
    else:
        branches = local_branches

    entries = []
    for branch in sorted(set(branches) - {"", "HEAD"}):
        remotes = remotes_by_branch.get(branch, [])
        display = f"{branch} [{', '.join(remotes)}]" if remotes else branch
        entries.append(f"{branch}\t{display}")

    selection = select_with_fzf(entries, "--delimiter=\t", "--with-nth=2")
    branch = selection.split("\t", 1)[0]
    if not branch:
        fail("No branch selected")

    local_ref = subprocess.run(
        ["git", "show-ref", "--verify", "--quiet", f"refs/heads/{branch}"],
        check=False,
    )
    if local_ref.returncode == 0:
        run_and_print(["git", "checkout", branch])
    if local_ref.returncode != 1:
        raise SystemExit(local_ref.returncode)

    remote_branches = [f"{remote}/{branch}" for remote in remotes_by_branch.get(branch, [])]
    if len(remote_branches) == 1:
        remote_branch = remote_branches[0]
    else:
        remote_branch = select_with_fzf(remote_branches, "--prompt=Select remote branch to track:")

    if not remote_branch:
        fail("No remote branch selected")
    run_and_print(["git", "checkout", "-b", branch, "--track", remote_branch])


if __name__ == "__main__":
    main()
