#!/usr/bin/env python3

# SPDX-License-Identifier: MIT-0 OR Unlicense

"""
Re-derive the manifest from data/ on disk and write it to stdout.

Used by the integrity CI to detect drift between data/ and the
committed data/_provenance/manifest.txt — if anyone modifies a file
under data/ without regenerating the manifest, the diff fails CI.

Output format matches manifest.txt exactly:
    <sha256-hex><two spaces><relpath>

Sorted by relpath (lexicographic). Excludes anything under
data/_provenance/ since that directory contains the manifest itself.
"""
from __future__ import annotations

import hashlib
import os
import sys
from pathlib import Path

DATA = Path(__file__).resolve().parent.parent / "data"


def sha256_of(p: Path) -> str:
    h = hashlib.sha256()
    with open(p, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 17), b""):
            h.update(chunk)
    return h.hexdigest()


def main() -> int:
    if not DATA.is_dir():
        print(f"error: {DATA} is not a directory", file=sys.stderr)
        return 2

    entries: list[tuple[str, str]] = []  # (relpath, sha)
    for dirpath, _, files in os.walk(DATA):
        rel_dir = Path(dirpath).relative_to(DATA).as_posix()
        if rel_dir == "_provenance" or rel_dir.startswith("_provenance/"):
            continue
        for name in files:
            full = Path(dirpath) / name
            rel = full.relative_to(DATA).as_posix()
            entries.append((rel, sha256_of(full)))

    entries.sort()
    for rel, sha in entries:
        sys.stdout.write(f"{sha}  {rel}\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
