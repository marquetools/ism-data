#!/usr/bin/env python3
# SPDX-License-Identifier: MIT-0 OR Unlicense

"""
Sync the crates.io publish allowlist from `tools/published.toml` into:

  1. Each per-package crate's `Cargo.toml` `publish` field.
  2. `crates/ism-data/src/lib.rs` — the `PUBLISHED_PACKAGES` slice between
     the `BEGIN GENERATED: PUBLISHED_PACKAGES` markers.
  3. `crates/ism-data/Cargo.toml` `publish` field.

`published.toml` is the single source of truth — this script only writes
derived state.

Idempotent. Run after editing `tools/published.toml`. Equivalent to
`split_into_crates.py --regen` for the publish-related fields, but surgical:
it does not regenerate manifests, build.rs, or the namespace tables.

Usage:
  python3 tools/sync_published.py            # apply changes
  python3 tools/sync_published.py --check    # exit 1 if out of sync (CI)
"""
from __future__ import annotations

import argparse
import re
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CRATES = ROOT / "crates"
PUBLISHED_TOML = ROOT / "tools" / "published.toml"
META_LIB_RS = CRATES / "ism-data" / "src" / "lib.rs"
META_CARGO_TOML = CRATES / "ism-data" / "Cargo.toml"

BEGIN_MARKER = "// ----- BEGIN GENERATED: PUBLISHED_PACKAGES -----"
END_MARKER = "// ----- END GENERATED: PUBLISHED_PACKAGES -----"

PUBLISH_LINE = "publish = true"
PUBLISH_BLOCK = (
    "# Override workspace default — listed in tools/published.toml.\n"
    + PUBLISH_LINE
)
# Match `publish = true` plus any contiguous run of leading `#` comment
# lines, so we cleanly replace whatever comment the user/script wrote
# previously. We rewrite to the canonical comment+line form.
EXISTING_PUBLISH_RE = re.compile(
    r"^(?:#[^\n]*\n)*publish = true\n",
    re.MULTILINE,
)
# We anchor inserts after the `repository.workspace = true` line. Every
# scaffolded per-crate Cargo.toml has it; the meta crate has it too.
ANCHOR_RE = re.compile(r"^repository\.workspace = true\n", re.MULTILINE)


def crate_name(pkg: str) -> str:
    # Mirror the special case in `crate_name_for` in crates/ism-data/src/lib.rs:
    # the ISM package's crate is named `ism`, not `ism-ism`.
    if pkg == "ISM":
        return "ism"
    return "ism-" + pkg.lower()


def load_published() -> dict:
    if not PUBLISHED_TOML.exists():
        sys.exit(f"missing {PUBLISHED_TOML}")
    with open(PUBLISHED_TOML, "rb") as fh:
        return tomllib.load(fh)


# --- per-crate Cargo.toml ---------------------------------------------------


def desired_cargo_toml(current: str, want_published: bool) -> str:
    """Return the desired contents of a Cargo.toml given current state.

    - If `want_published` and a publish line is missing: inject after
      `repository.workspace = true`.
    - If not `want_published` and a publish line is present: remove it.
    - Otherwise: return current unchanged.
    """
    has_publish = bool(EXISTING_PUBLISH_RE.search(current))
    if want_published == has_publish:
        # Even if the line exists, normalize its form (with comment).
        if want_published:
            return EXISTING_PUBLISH_RE.sub(PUBLISH_BLOCK + "\n", current, count=1)
        return current

    if want_published:
        anchor = ANCHOR_RE.search(current)
        if not anchor:
            raise RuntimeError(
                "Cargo.toml missing `repository.workspace = true` anchor"
            )
        insert_at = anchor.end()
        return current[:insert_at] + PUBLISH_BLOCK + "\n" + current[insert_at:]
    # remove
    return EXISTING_PUBLISH_RE.sub("", current, count=1)


def sync_per_crate(published_pkgs: set[str], check_only: bool) -> list[str]:
    """Apply publish field updates to every per-package crate. Returns list
    of crate names that needed (or would need) an update."""
    drift: list[str] = []
    for cdir in sorted(CRATES.iterdir()):
        if not cdir.is_dir():
            continue
        if cdir.name == "ism-data":
            # Meta crate handled separately by sync_meta_cargo_toml.
            continue
        cargo = cdir / "Cargo.toml"
        if not cargo.exists():
            continue
        # Reverse the cargo-name → package-name lookup for [packages] keys.
        # We can't trivially reverse "IC-Docbook" -> "ism-ic-docbook" without
        # the original casing, so derive want_published from the crate dir
        # name: its lowercase form must match an entry's lowercase form.
        want = any(
            cdir.name == crate_name(pkg) for pkg in published_pkgs
        )
        current = cargo.read_text(encoding="utf-8")
        desired = desired_cargo_toml(current, want)
        if desired != current:
            drift.append(cdir.name)
            if not check_only:
                cargo.write_text(desired, encoding="utf-8")
    return drift


# --- meta crate Cargo.toml --------------------------------------------------


def sync_meta_cargo_toml(meta_published: bool, check_only: bool) -> bool:
    """Ensure crates/ism-data/Cargo.toml's publish field matches `[meta]`.
    Returns True if a change was needed."""
    current = META_CARGO_TOML.read_text(encoding="utf-8")
    desired = desired_cargo_toml(current, meta_published)
    if desired == current:
        return False
    if not check_only:
        META_CARGO_TOML.write_text(desired, encoding="utf-8")
    return True


# --- meta crate lib.rs marker block ----------------------------------------


def render_published_block(published_pkgs: set[str]) -> str:
    """Build the contents that go between BEGIN/END markers (exclusive)."""
    sorted_pkgs = sorted(published_pkgs)
    if not sorted_pkgs:
        body = "pub const PUBLISHED_PACKAGES: &[&str] = &[];"
    else:
        lines = ["pub const PUBLISHED_PACKAGES: &[&str] = &["]
        for pkg in sorted_pkgs:
            lines.append(f'    "{pkg}",')
        lines.append("];")
        body = "\n".join(lines)
    return body


def sync_meta_lib_rs(published_pkgs: set[str], check_only: bool) -> bool:
    """Replace contents between BEGIN/END markers in ism-data/src/lib.rs.
    Returns True if a change was needed."""
    src = META_LIB_RS.read_text(encoding="utf-8")
    begin = src.find(BEGIN_MARKER)
    end = src.find(END_MARKER)
    if begin == -1 or end == -1 or end < begin:
        sys.exit(
            f"missing {BEGIN_MARKER!r} / {END_MARKER!r} markers in {META_LIB_RS}"
        )
    block_start = begin + len(BEGIN_MARKER) + 1  # skip newline after marker
    block_end = end  # marker line itself stays; we replace up to (but not including) it
    new_block = render_published_block(published_pkgs) + "\n"
    desired = src[:block_start] + new_block + src[block_end:]
    if desired == src:
        return False
    if not check_only:
        META_LIB_RS.write_text(desired, encoding="utf-8")
    return True


# --- main -------------------------------------------------------------------


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--check",
        action="store_true",
        help="exit 1 if any file would be changed (for CI)",
    )
    args = ap.parse_args()

    cfg = load_published()
    package_pkgs: set[str] = set(cfg.get("packages", {}).keys())
    meta_pkgs: set[str] = set(cfg.get("meta", {}).keys())
    if "ism-data" not in meta_pkgs:
        # Mirror the policy: the meta crate should always be in [meta]. Warn
        # rather than fail so the script can still flip it off if desired.
        print(
            "warn: tools/published.toml [meta] does not list \"ism-data\" — "
            "consumers cannot resolve namespaces without the meta crate",
            file=sys.stderr,
        )

    drift_per_crate = sync_per_crate(package_pkgs, check_only=args.check)
    drift_meta_cargo = sync_meta_cargo_toml(
        meta_published="ism-data" in meta_pkgs, check_only=args.check
    )
    drift_meta_lib = sync_meta_lib_rs(package_pkgs, check_only=args.check)

    any_drift = bool(drift_per_crate) or drift_meta_cargo or drift_meta_lib
    verb = "would update" if args.check else "updated"

    if drift_per_crate:
        print(
            f"{verb} {len(drift_per_crate)} per-crate Cargo.toml: "
            f"{', '.join(drift_per_crate)}",
            file=sys.stderr,
        )
    if drift_meta_cargo:
        print(f"{verb} crates/ism-data/Cargo.toml", file=sys.stderr)
    if drift_meta_lib:
        print(f"{verb} crates/ism-data/src/lib.rs", file=sys.stderr)
    if not any_drift:
        print("already in sync with tools/published.toml", file=sys.stderr)

    if args.check and any_drift:
        print(
            "error: derived files do not match tools/published.toml. "
            "Run `python3 tools/sync_published.py` to fix.",
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
