#!/usr/bin/env python3
"""
Reproduce the manifest from a directory of upstream ODNI zip files.

Used by the reproduce-from-zips CI workflow to verify that the
consolidation process is deterministic. Given the same input zips, the
same set of files (with the same SHA-256s) must come out — or someone
has tampered with the data/ tree, the consolidation tool, or the zips.

USAGE
-----
  reproduce_from_zips.py --zips DIR [--manifest manifest.txt] \
                         [--provenance provenance.toml]

WHAT IT DOES
------------
1. Verify each zip's SHA-256 against the recorded provenance.toml
   (if provided). Bail on mismatch — the inputs aren't what we
   expected, no point continuing.
2. Extract every zip into a clean staging area.
3. Walk every package's tree and compute SHA-256 for each file.
4. Build a sorted manifest.txt-format output: "<sha>  <pkg>/<rel>"
5. Diff against the committed manifest.txt. Exit non-zero on mismatch.

WHY NOT GO THROUGH consolidate.py?
----------------------------------
consolidate.py is responsible for the dedup/symlink layout, which is a
delivery optimization. The security boundary is "do the upstream bytes
hash to the manifest we shipped?". That question is independent of how
files are organized inside the crate, so we can answer it more directly
(and with less code) by hashing files immediately after unzip.
"""
from __future__ import annotations

import argparse
import hashlib
import os
import sys
import tempfile
import zipfile
from pathlib import Path


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
            # Started a different table; flush.
            if cur_name and cur_sha:
                out[cur_name] = cur_sha
            cur_name = cur_sha = None
            in_zip_section = False
    if cur_name and cur_sha:
        out[cur_name] = cur_sha
    return out


def verify_zips(zips_dir: Path, expected: dict[str, str]) -> list[str]:
    """Return list of human-readable mismatch messages."""
    errors: list[str] = []
    if not expected:
        return ["provenance.toml has no [[upstream_zips]] entries — cannot verify zip identities"]
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
    """Extract every zip into dst/. Each zip should contain one top-level dir."""
    dst.mkdir(parents=True, exist_ok=True)
    for zip_path in sorted(zips_dir.glob("*.zip")):
        with zipfile.ZipFile(zip_path) as zf:
            zf.extractall(dst)


def derive_manifest(extracted: Path) -> str:
    """Hash every file under extracted/<pkg>/, return sorted manifest text."""
    entries: list[tuple[str, str]] = []
    for pkg_dir in extracted.iterdir():
        if not pkg_dir.is_dir():
            continue
        pkg_name = pkg_dir.name
        for dirpath, _, files in os.walk(pkg_dir):
            for fname in files:
                full = Path(dirpath) / fname
                rel_pkg = full.relative_to(pkg_dir).as_posix()
                rel_data = f"{pkg_name}/{rel_pkg}"
                entries.append((rel_data, sha256_of(full)))
    entries.sort()
    return "".join(f"{sha}  {rel}\n" for rel, sha in entries)


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--zips", required=True, type=Path,
                    help="Directory containing the upstream *.zip files.")
    ap.add_argument("--manifest", type=Path,
                    default=Path(__file__).resolve().parent.parent
                              / "data/_provenance/manifest.txt",
                    help="Path to the committed manifest.txt to compare against.")
    ap.add_argument("--provenance", type=Path,
                    default=Path(__file__).resolve().parent.parent
                              / "data/_provenance/provenance.toml",
                    help="Path to provenance.toml carrying expected zip hashes.")
    args = ap.parse_args(argv)

    if not args.zips.is_dir():
        print(f"error: {args.zips} is not a directory", file=sys.stderr)
        return 2

    print(f"Step 1/4: verify zip hashes against {args.provenance}", file=sys.stderr)
    expected_zips = parse_provenance(args.provenance) if args.provenance.exists() else {}
    if not expected_zips:
        print("  WARN: no zip hashes in provenance.toml — proceeding without input verification",
              file=sys.stderr)
    else:
        errs = verify_zips(args.zips, expected_zips)
        if errs:
            print("FAIL: zip identity check:", file=sys.stderr)
            for e in errs:
                print(f"  {e}", file=sys.stderr)
            return 1
        print(f"  OK: {len(expected_zips)} zips match provenance.toml", file=sys.stderr)

    with tempfile.TemporaryDirectory(prefix="reproduce_") as tmp:
        extracted = Path(tmp) / "extracted"
        print(f"Step 2/4: extract zips to {extracted}", file=sys.stderr)
        extract_zips(args.zips, extracted)
        n_pkgs = sum(1 for p in extracted.iterdir() if p.is_dir())
        print(f"  OK: extracted {n_pkgs} packages", file=sys.stderr)

        print("Step 3/4: hash every file and build manifest", file=sys.stderr)
        derived = derive_manifest(extracted)
        n_lines = derived.count("\n")
        print(f"  OK: hashed {n_lines} files", file=sys.stderr)

        print(f"Step 4/4: diff against {args.manifest}", file=sys.stderr)
        committed = args.manifest.read_text() if args.manifest.exists() else ""
        if derived == committed:
            print(f"  OK: derived manifest matches committed manifest exactly", file=sys.stderr)
            return 0
        # Show a brief diff
        derived_lines = set(derived.splitlines())
        committed_lines = set(committed.splitlines())
        only_committed = sorted(committed_lines - derived_lines)
        only_derived = sorted(derived_lines - committed_lines)
        print("FAIL: manifest mismatch", file=sys.stderr)
        print(f"  in committed but not derived: {len(only_committed)} lines", file=sys.stderr)
        print(f"  in derived but not committed: {len(only_derived)} lines", file=sys.stderr)
        for line in only_committed[:5]:
            print(f"    -{line}", file=sys.stderr)
        for line in only_derived[:5]:
            print(f"    +{line}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
