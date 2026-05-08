#!/usr/bin/env python3

# SPDX-License-Identifier: MIT-0 OR Unlicense

"""
Re-derive each per-package crate's manifest from data/ on disk.

Used by the integrity CI to detect drift between
`crates/<crate>/data/` and the committed
`crates/<crate>/data/_provenance/manifest.txt`. If anyone modifies a
file under any crate's data/ without regenerating the manifest, the
diff fails CI.

Modes:

  rederive_manifest.py
      Default: walk every crates/<crate>/data/ and compare against
      the committed manifest.txt + manifest.sha256 + the
      MANIFEST_DIGEST const in src/lib.rs. Exit non-zero on any
      mismatch.

  rederive_manifest.py --write
      Same walk, but rewrite manifest.txt + manifest.sha256 +
      MANIFEST_DIGEST in lib.rs in-place. Run this after a
      legitimate change to data/ before committing.

  rederive_manifest.py --crate ism-ismcat
      Limit to one or more crates (repeatable).
"""
from __future__ import annotations

import argparse
import difflib
import hashlib
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CRATES_DIR = ROOT / "crates"


def sha256_of(p: Path) -> str:
    h = hashlib.sha256()
    with open(p, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 17), b""):
            h.update(chunk)
    return h.hexdigest()


def derive_manifest(data_dir: Path) -> tuple[str, str]:
    """Walk data_dir, return (manifest_text, manifest_digest)."""
    entries: list[tuple[str, str]] = []
    for dirpath, _, files in os.walk(data_dir):
        rel_dir = Path(dirpath).relative_to(data_dir).as_posix()
        if rel_dir == "_provenance" or rel_dir.startswith("_provenance/"):
            continue
        for name in files:
            full = Path(dirpath) / name
            rel = full.relative_to(data_dir).as_posix()
            entries.append((rel, sha256_of(full)))
    entries.sort()
    text = "".join(f"{sha}  {rel}\n" for rel, sha in entries)
    digest = hashlib.sha256(text.encode("utf-8")).hexdigest()
    return text, digest


MANIFEST_DIGEST_RE = re.compile(
    r'pub const MANIFEST_DIGEST: &str = "([0-9a-f]{64})";'
)
FILE_COUNT_RE = re.compile(r"pub const FILE_COUNT: usize = (\d+);")


def update_lib_rs(
    lib_path: Path, new_digest: str, new_count: int
) -> bool:
    """Replace MANIFEST_DIGEST and FILE_COUNT consts. Returns True if changed."""
    src = lib_path.read_text(encoding="utf-8")
    new_src = MANIFEST_DIGEST_RE.sub(
        f'pub const MANIFEST_DIGEST: &str = "{new_digest}";', src, count=1
    )
    new_src = FILE_COUNT_RE.sub(
        f"pub const FILE_COUNT: usize = {new_count};", new_src, count=1
    )
    if new_src != src:
        lib_path.write_text(new_src, encoding="utf-8")
        return True
    return False


def process_crate(crate_dir: Path, write: bool) -> tuple[bool, list[str]]:
    """Process one crate. Returns (clean, diffs)."""
    data_dir = crate_dir / "data"
    if not data_dir.is_dir():
        return True, []

    derived_text, derived_digest = derive_manifest(data_dir)
    derived_count = derived_text.count("\n")

    manifest_path = data_dir / "_provenance" / "manifest.txt"
    digest_path = data_dir / "_provenance" / "manifest.sha256"
    lib_path = crate_dir / "src" / "lib.rs"

    diffs: list[str] = []
    clean = True

    # 1. manifest.txt
    committed_text = (
        manifest_path.read_text(encoding="utf-8") if manifest_path.exists() else ""
    )
    if committed_text != derived_text:
        clean = False
        if write:
            manifest_path.write_text(derived_text, encoding="utf-8")
            diffs.append(f"  + rewrote {manifest_path.relative_to(ROOT)}")
        else:
            diffs.append(
                f"  ! {manifest_path.relative_to(ROOT)} differs from data/"
            )
            d = list(
                difflib.unified_diff(
                    committed_text.splitlines(keepends=True),
                    derived_text.splitlines(keepends=True),
                    fromfile=f"committed/{manifest_path.relative_to(ROOT)}",
                    tofile=f"derived/{manifest_path.relative_to(ROOT)}",
                    n=1,
                )
            )[:30]
            diffs.extend("    " + line.rstrip("\n") for line in d)

    # 2. manifest.sha256
    committed_digest = (
        digest_path.read_text(encoding="utf-8").strip()
        if digest_path.exists()
        else ""
    )
    if committed_digest != derived_digest:
        clean = False
        if write:
            digest_path.write_text(derived_digest + "\n", encoding="utf-8")
            diffs.append(
                f"  + rewrote {digest_path.relative_to(ROOT)} -> {derived_digest}"
            )
        else:
            diffs.append(
                f"  ! {digest_path.relative_to(ROOT)}: "
                f"committed={committed_digest} derived={derived_digest}"
            )

    # 3. MANIFEST_DIGEST + FILE_COUNT consts in lib.rs
    if lib_path.exists():
        lib_src = lib_path.read_text(encoding="utf-8")
        m = MANIFEST_DIGEST_RE.search(lib_src)
        c = FILE_COUNT_RE.search(lib_src)
        const_digest = m.group(1) if m else ""
        const_count = int(c.group(1)) if c else -1
        if const_digest != derived_digest or const_count != derived_count:
            clean = False
            if write:
                if update_lib_rs(lib_path, derived_digest, derived_count):
                    diffs.append(
                        f"  + updated MANIFEST_DIGEST + FILE_COUNT in "
                        f"{lib_path.relative_to(ROOT)}"
                    )
            else:
                if const_digest != derived_digest:
                    diffs.append(
                        f"  ! MANIFEST_DIGEST in {lib_path.relative_to(ROOT)}: "
                        f"const={const_digest} derived={derived_digest}"
                    )
                if const_count != derived_count:
                    diffs.append(
                        f"  ! FILE_COUNT in {lib_path.relative_to(ROOT)}: "
                        f"const={const_count} derived={derived_count}"
                    )

    return clean, diffs


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--write",
        action="store_true",
        help="rewrite committed manifests + lib.rs to match data/ on disk",
    )
    ap.add_argument(
        "--crate",
        action="append",
        default=None,
        help="limit to one or more crates by name (repeatable). "
        "Default: every crate with a data/ directory.",
    )
    args = ap.parse_args()

    if args.crate:
        targets = [CRATES_DIR / c for c in args.crate]
    else:
        targets = sorted(
            p for p in CRATES_DIR.iterdir() if p.is_dir() and (p / "data").is_dir()
        )

    failed = 0
    for crate in targets:
        clean, diffs = process_crate(crate, args.write)
        if clean:
            print(f"OK {crate.name}", file=sys.stderr)
        else:
            failed += 1
            print(f"DRIFT {crate.name}", file=sys.stderr)
            for d in diffs:
                print(d, file=sys.stderr)

    if failed and not args.write:
        print(
            f"\n{failed} crate(s) have manifest drift. "
            "Run `tools/rederive_manifest.py --write` and commit.",
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
