#!/usr/bin/env python3

import argparse
import glob
import os
import platform
import stat
import subprocess
from dataclasses import dataclass
from typing import Set


@dataclass
class CopyOpts:
    target: str
    allow_absent: bool = False


CONST_COMMENT_INSTRUCTION: str = "#"
CONST_INCLUDE_INSTRUCTION: str = "@include"
MAC_VER = float(platform.mac_ver()[0])
VENTURA_VER = 13


def build_queue(input_files: [str]) -> dict[str, CopyOpts]:
    files = list(input_files)
    queue: dict[str, CopyOpts] = dict()
    visited: set[str] = set()

    while len(files) > 0:
        file = os.path.abspath(files.pop())

        if file in visited:
            raise AssertionError(f"same input file specified multiple times: {file}")
        visited.add(file)

        with open(file) as f:
            for line in f.read().splitlines():
                line = line.strip()
                if len(line) <= 0:
                    continue

                if line.startswith(CONST_COMMENT_INSTRUCTION):
                    continue

                if line.startswith(CONST_INCLUDE_INSTRUCTION):
                    include_file = line[len(CONST_INCLUDE_INSTRUCTION) :].strip()
                    files.append(os.path.join(os.path.dirname(file), include_file))

                parts = line.split(" ")

                srcs = parts[0]
                for src in glob.glob(srcs):
                    if len(parts) == 1:
                        dst = parts[0]
                    elif len(parts) == 2:
                        dst = parts[1]
                    else:
                        raise AssertionError()
                    queue[src] = CopyOpts(target=dst)

    return queue


def copy_files(target_dir: str, queue: dict[str, CopyOpts]) -> None:
    visited: Set[str] = set()

    while len(queue) > 0:
        source_path, copy_opts = queue.popitem()
        visited.add(source_path)

        try:
            st = os.lstat(source_path)
        except FileNotFoundError:
            if copy_opts.allow_absent:
                # This happens due to dynamic linker cache on Big Sur and later
                continue
            else:
                raise

        full_target_path = target_dir + copy_opts.target

        # TODO: Preserve dir permissions
        os.makedirs(os.path.dirname(full_target_path), exist_ok=True)

        subprocess.check_call(["rsync", "-ah", source_path, full_target_path])

        if MAC_VER < VENTURA_VER and stat.S_ISREG(st.st_mode):
            otool_output = ""
            try:
                otool_output = (
                    subprocess.check_output(
                        ["/usr/bin/otool", "-L", source_path], stderr=subprocess.STDOUT
                    )
                    .decode("UTF-8")
                    .split("\n")
                )
            except subprocess.CalledProcessError as err:
                # Treat this error as warning (do not abort on macOS Monterey)
                otool_error_datalayout = (
                    "LLVM ERROR: Sized aggregate specification in datalayout string"
                )
                if err.stdout.decode("UTF-8").startswith(otool_error_datalayout):
                    print(otool_error_datalayout)
                    print("for command:")
                    print(err.args)
                else:
                    raise err

            for line in otool_output:
                if not line.startswith("\t"):
                    continue

                dependency = line.lstrip().split("(", 1)[0].rstrip()
                if dependency in visited:
                    continue

                queue[dependency] = CopyOpts(target=dependency, allow_absent=True)
        elif stat.S_ISDIR(st.st_mode):
            for d, _, files in os.walk(source_path):
                for f in files:
                    f_path = os.path.join(d, f)
                    if f_path not in visited and f_path not in queue:
                        queue[f_path] = CopyOpts(target=f_path)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "jail_dir",
        metavar="JAIL_DIR",
        help="Path to directory where jail chroot will be created",
    )
    parser.add_argument(
        "-f",
        "--files",
        default=[],
        action="append",
        metavar="JAIL_FILES",
        help="Jail file(s) to use",
    )
    args = parser.parse_args()

    files = args.files
    if len(files) <= 0:
        script_dir = os.path.abspath(os.path.dirname(__file__))
        files = [os.path.join(script_dir, "mkjail.files")]

    queue = build_queue(files)

    copy_files(args.jail_dir, queue)

    # I'm not sure what this file does
    chroot_marker = os.path.join(args.jail_dir, "AppleInternal", "XBS", ".isChrooted")
    os.makedirs(os.path.dirname(chroot_marker), exist_ok=True)
    open(chroot_marker, "a").close()

    # TODO: We do not want this to appear in docker image. Make separate build/run commands?
    # mDNSResponder = os.path.join(jail_dir, "var", "run", "mDNSResponder")
    # os.makedirs(os.path.dirname(mDNSResponder), exist_ok=True)
    # # This makes DNS work inside chroot
    # os.link("/var/run/mDNSResponder", mDNSResponder)
