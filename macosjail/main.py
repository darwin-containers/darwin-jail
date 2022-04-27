#!/usr/bin/env python3

import argparse
import os
import stat
import subprocess
from typing import Set


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("jail_dir", metavar="JAIL_DIR", help="Path to directory where jail chroot will be created")
    args = parser.parse_args()

    script_dir = os.path.abspath(os.path.dirname(__file__))

    queue: Set[str] = set()
    with open(os.path.join(script_dir, "mkjail.files")) as f:
        queue.update(f.read().splitlines())

    visited: Set[str] = set()

    jail_dir: str = args.jail_dir

    while len(queue) > 0:
        source_path = queue.pop()
        visited.add(source_path)

        try:
            st = os.stat(source_path)
        except FileNotFoundError:
            # This happens due to dynamic linker cache on Big Sur and later
            continue

        target_path = jail_dir + source_path

        # TODO: Preserve dir permissions
        os.makedirs(os.path.dirname(target_path), exist_ok=True)

        subprocess.check_call(["/usr/bin/rsync", "-ah", source_path, target_path])

        if stat.S_ISREG(st.st_mode):
            otool_output = subprocess.check_output(["/usr/bin/otool", "-L", source_path]).decode("UTF-8").split("\n")
            for line in otool_output:
                if not line.startswith("\t"):
                    continue

                dependency = line.lstrip().split("(", 1)[0].rstrip()
                if dependency in visited:
                    continue

                queue.add(dependency)
        elif stat.S_ISDIR(st.st_mode):
            for d, _, files in os.walk(source_path):
                for f in files:
                    queue.add(os.path.join(d, f))
