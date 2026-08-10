#!/usr/bin/env python3

import argparse
import os
import shlex
import shutil
import subprocess
import sys
import time
from pathlib import Path

################################################################################
# CONFIG
################################################################################

CACHE_SIZE = "10G"
BUFFER_SIZE = "256M"

MOUNTS = [
    {
        "name": "gdrive",
        "remote": "gdrive:",
        "path": Path.home() / "gdrive",
        "extra": [],
    },
    {
        "name": "gdrive-u",
        "remote": "gdrive-u:",
        "path": Path.home() / "gdrive-u",
        "extra": [],
    },
    {
        "name": "shared",
        "remote": "gdrive:",
        "path": Path.home() / "gdrive-shared",
        "extra": ["--drive-shared-with-me"],
    },
]

################################################################################
# LOGGING
################################################################################

USE_COLOR = sys.stdout.isatty()

def colour(name: str) -> str:
    return os.getenv(name, "") if USE_COLOR else ""

RESET   = colour("_CLR_RESET")
BOLD    = colour("_CLR_BOLD")
INFO_C  = colour("_CLR_INFO")
OK_C    = colour("_CLR_SUCCESS")
WARN_C  = colour("_CLR_WARN")
ERR_C   = colour("_CLR_ERROR")
CMD_C   = colour("_CLR_ACCENT")


def _log(prefix, colour_code, *msg, stream=sys.stdout):
    print(f"{colour_code}{prefix:<5}{RESET}", *msg, file=stream)


def info(*msg):
    _log("INFO", INFO_C, *msg)


def success(*msg):
    _log("OK", OK_C, *msg)


def warn(*msg):
    _log("WARN", WARN_C, *msg)


def error(*msg):
    _log("FAIL", ERR_C, *msg, stream=sys.stderr)


def command(cmd):
    if isinstance(cmd, (list, tuple)):
        cmd = shlex.join(map(str, cmd))
    _log("$", CMD_C, cmd)


################################################################################
# HELPERS
################################################################################

BACKGROUND = False


def notify(title, msg):
    if BACKGROUND and shutil.which("notify-send"):
        subprocess.run(
            ["notify-send", title, msg],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )


def run(cmd, capture=True):

    command(cmd)

    return subprocess.run(
        cmd,
        text=True,
        capture_output=capture,
    )


def mounted(path: Path):

    return (
        subprocess.run(
            ["mountpoint", "-q", str(path)],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        ).returncode
        == 0
    )


################################################################################
# RCLOUD
################################################################################


def reconnect(remote):

    print()

    ans = input(f"Reconnect {remote}? [Y/n] ").strip().lower()

    if ans not in ("", "y", "yes"):
        return False

    result = subprocess.run(["rclone", "config", "reconnect", remote])

    return result.returncode == 0


def check_remote(remote):

    result = run(["rclone", "about", remote])

    if result.returncode == 0:
        return True

    stderr = (result.stderr or "").lower()

    auth_words = (
        "oauth",
        "invalid_grant",
        "token",
        "expired",
        "unauthorized",
    )

    if any(word in stderr for word in auth_words):

        warn("Authentication appears to have failed.")

        if reconnect(remote):
            success("Reconnect successful. Retrying...")
            return check_remote(remote)

        error("Reconnect failed.")

    else:

        error(result.stderr.strip())

    return False


################################################################################
# MOUNT
################################################################################


def mount_one(cfg):

    name = cfg["name"]
    remote = cfg["remote"]
    path = cfg["path"]

    info(f"Mounting {name}")

    path.mkdir(parents=True, exist_ok=True)

    if mounted(path):
        success(f"{name} already mounted.")
        return

    if not check_remote(remote):
        error(f"{name}: remote unavailable")
        notify(f"{name} failed", "Authentication or connectivity issue.")
        return

    cmd = [
        "rclone",
        "mount",
        remote,
        str(path),
        "--daemon",
        "--vfs-cache-mode",
        "full",
        "--vfs-cache-max-size",
        CACHE_SIZE,
        "--buffer-size",
        BUFFER_SIZE,
        *cfg["extra"],
    ]

    result = run(cmd)

    if result.returncode != 0:
        error(result.stderr.strip())
        notify(f"{name} failed", "Mount command failed.")
        return

    time.sleep(2)

    if mounted(path):
        success(f"Mounted {name}")
    else:
        error(f"Failed to mount {name}")
        notify(f"{name} failed", "Mount verification failed.")


################################################################################
# UNMOUNT
################################################################################


def unmount_one(cfg):

    name = cfg["name"]
    path = cfg["path"]

    if not mounted(path):
        info(f"{name} is not mounted.")
        return

    info(f"Unmounting {name}")

    result = subprocess.run(["fusermount", "-u", str(path)])

    if result.returncode == 0:
        success(f"Unmounted {name}")
        return

    warn("Normal unmount failed, trying lazy unmount.")

    result = subprocess.run(["fusermount", "-uz", str(path)])

    if result.returncode == 0:
        success(f"Lazy unmounted {name}")
    else:
        error(f"Failed to unmount {name}")


################################################################################
# CLI
################################################################################

parser = argparse.ArgumentParser(
    prog="gmount",
    description="Mount/unmount rclone Google Drive remotes.",
)

parser.add_argument(
    "--shared",
    action="store_true",
    help="Include the 'Shared with me' mount.",
)

parser.add_argument(
    "--unmount",
    action="store_true",
    help="Unmount instead of mounting.",
)

parser.add_argument(
    "--bg",
    action="store_true",
    help="Background mode (desktop notifications).",
)

args = parser.parse_args()

BACKGROUND = args.bg

################################################################################
# MAIN
################################################################################

mounts = MOUNTS[:2]

if args.shared:
    mounts.append(MOUNTS[2])

try:

    if args.unmount:
        for mount in mounts:
            unmount_one(mount)
    else:
        for mount in mounts:
            mount_one(mount)

except KeyboardInterrupt:
    warn("Interrupted.")
    sys.exit(130)

success("Done.")
