#!/usr/bin/env python3

# SPDX-License-Identifier: MIT-0 OR Unlicense

"""
Reproduce per-crate manifests from a directory of upstream ODNI zip files.

Used by the reproduce-from-zips CI workflow to verify that the
consolidation process is deterministic. Given the same input zips, the
same set of files (with the same SHA-256s) must come out — or someone
has tampered with the data/ tree, the consolidation tool, or the zips.

USAGE
-----
  reproduce_from_zips.py --zips DIR [--provenance provenance.toml]

WHAT IT DOES
------------
1. Verify each zip's SHA-256 against the recorded provenance.toml
   (if provided). Bail on mismatch.
2. Extract every zip into a clean staging area.
3. For each top-level <pkg> dir in the extraction, find the matching
   crates/ism-<pkg>/data/_provenance/manifest.txt and compare the
   re-hashed contents line-by-line.
4. Exit non-zero on any mismatch.

WHY NOT GO THROUGH consolidate.py?
----------------------------------
consolidate.py is responsible for the dedup/symlink layout — a delivery
optimization. The security boundary is "do the upstream bytes hash to
the manifests we shipped?". That question is independent of how files
are organized inside crates, so we answer it more directly by hashing
files immediately after unzip.
"""
from __future__ import annotations

import argparse
import hashlib
import os
import sys
import tempfile
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CRATES = ROOT / "crates"


def sha256_of(p: Path) -> str:
    h = hashlib.sha256()
    with open(p, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 17), b""):
            h.update(chunk)
    return h.hexdigest()


def parse_provenance(path: Path) -> dict[str, str]:
    """Return {zip-filename: sha256} from provenance.toml."""
    out: dict[str, str] = {}
    cur_name: str | None = None
    cur_sha: str | None = None
    in_zip_section = False
    for line in path.read_text().splitlines():
        s = line.strip()
        if s == "[[upstream_zips]]":
            if cur_name and cur_sha:
                out[cur_name] = cur_sha
            cur_name = cur_sha = None
            in_zip_section = True
            continue
        if not in_zip_section or not s or s.startswith("#"):
            continue
        if s.startswith("name = "):
            cur_name = s.split("=", 1)[1].strip().strip('"')
        elif s.startswith("sha256 = "):
            cur_sha = s.split("=", 1)[1].strip().strip('"')
        elif s.startswith("["):
            if cur_name and cur_sha:
                out[cur_name] = cur_sha
            cur_name = cur_sha = None
            in_zip_section = False
    if cur_name and cur_sha:
        out[cur_name] = cur_sha
    return out


def verify_zips(zips_dir: Path, expected: dict[str, str]) -> list[str]:
    errors: list[str] = []
    if not expected:
        return [
            "provenance.toml has no [[upstream_zips]] entries — "
            "cannot verify zip identities"
        ]
    for name, expected_sha in expected.items():
        candidate = zips_dir / name
        if not candidate.exists():
            errors.append(f"missing zip: {name}")
            continue
        actual = sha256_of(candidate)
        if actual != expected_sha:
            errors.append(
                f"zip hash mismatch: {name}\n"
                f"  expected: {expected_sha}\n"
                f"  actual:   {actual}"
            )
    return errors


def extract_zips(zips_dir: Path, dst: Path) -> None:
    dst.mkdir(parents=True, exist_ok=True)
    for zip_path in sorted(zips_dir.glob("*.zip")):
        with zipfile.ZipFile(zip_path) as zf:
            zf.extractall(dst)


def derive_pkg_manifest(pkg_dir: Path, pkg_name: str) -> str:
    """Hash every file under pkg_dir, return manifest text in '<sha>  <pkg>/<rel>' form."""
    entries: list[tuple[str, str]] = []
    for dirpath, _, files in os.walk(pkg_dir):
        for fname in files:
            full = Path(dirpath) / fname
            rel = full.relative_to(pkg_dir).as_posix()
            entries.append((f"{pkg_name}/{rel}", sha256_of(full)))
    entries.sort()
    return "".join(f"{sha}  {rel}\n" for rel, sha in entries)


def find_crate_for_package(pkg_name: str) -> Path | None:
    cdir = CRATES / f"ism-{pkg_name.lower()}"
    return cdir if cdir.is_dir() else None


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--zips",
        required=True,
        type=Path,
        help="Directory containing the upstream *.zip files.",
    )
    ap.add_argument(
        "--provenance",
        type=Path,
        default=ROOT / "provenance.toml",
        help="Path to provenance.toml carrying expected zip hashes.",
    )
    args = ap.parse_args(argv)

    if not args.zips.is_dir():
        print(f"error: {args.zips} is not a directory", file=sys.stderr)
        return 2

    print(f"Step 1/4: verify zip hashes against {args.provenance}", file=sys.stderr)
    expected_zips = parse_provenance(args.provenance) if args.provenance.exists() else {}
    if not expected_zips:
        print(
            "  WARN: no zip hashes in provenance.toml — "
            "proceeding without input verification",
            file=sys.stderr,
        )
    else:
        errs = verify_zips(args.zips, expected_zips)
        if errs:
            print("FAIL: zip identity check:", file=sys.stderr)
            for e in errs:
                print(f"  {e}", file=sys.stderr)
            return 1
        print(
            f"  OK: {len(expected_zips)} zips match provenance.toml",
            file=sys.stderr,
        )

    with tempfile.TemporaryDirectory(prefix="reproduce_") as tmp:
        extracted = Path(tmp) / "extracted"
        print(f"Step 2/4: extract zips to {extracted}", file=sys.stderr)
        extract_zips(args.zips, extracted)
        pkg_dirs = sorted(p for p in extracted.iterdir() if p.is_dir())
        print(f"  OK: extracted {len(pkg_dirs)} packages", file=sys.stderr)

        print("Step 3/4: hash every file per-package", file=sys.stderr)
        per_pkg: dict[str, str] = {}
        for pdir in pkg_dirs:
            per_pkg[pdir.name] = derive_pkg_manifest(pdir, pdir.name)
        total_lines = sum(t.count("\n") for t in per_pkg.values())
        print(f"  OK: hashed {total_lines} files across {len(per_pkg)} packages", file=sys.stderr)

        print("Step 4/4: diff each derived manifest against the committed per-crate manifest",
              file=sys.stderr)
        failed = 0
        for pkg, derived in per_pkg.items():
            crate = find_crate_for_package(pkg)
            if crate is None:
                print(f"  FAIL {pkg}: no matching ism-{pkg.lower()} crate", file=sys.stderr)
                failed += 1
                continue
            committed_path = crate / "data" / "_provenance" / "manifest.txt"
            committed = (
                committed_path.read_text(encoding="utf-8")
                if committed_path.exists()
                else ""
            )
            if derived == committed:
                print(f"  OK   {pkg} ({derived.count(chr(10))} files)", file=sys.stderr)
                continue
            failed += 1
            derived_lines = set(derived.splitlines())
            committed_lines = set(committed.splitlines())
            only_committed = sorted(committed_lines - derived_lines)
            only_derived = sorted(derived_lines - committed_lines)
            print(
                f"  FAIL {pkg}: -{len(only_committed)} +{len(only_derived)}",
                file=sys.stderr,
            )
            for line in only_committed[:3]:
                print(f"    -{line}", file=sys.stderr)
            for line in only_derived[:3]:
                print(f"    +{line}", file=sys.stderr)

        if failed:
            print(
                f"\n{failed} package(s) failed reproduction.",
                file=sys.stderr,
            )
            return 1
        print(
            f"\nAll {len(per_pkg)} packages reproduced exactly from upstream zips.",
            file=sys.stderr,
        )
        return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
