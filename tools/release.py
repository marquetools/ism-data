#!/usr/bin/env python3
# SPDX-License-Identifier: MIT-0 OR Unlicense

"""
Publish workspace crates to crates.io per the `tools/published.toml`
allowlist.

What this does:
  1. Reads `tools/published.toml` for which crates should be published.
  2. Reads `workspace.package.version` from `Cargo.toml`.
  3. Queries crates.io for the current state of each crate:
       - new (404)         → first-ever publish; pace at the new-crate rate limit
       - exists, missing v → fast publish of the new version
       - exists, has v     → already published; skip (resume support)
  4. Prints the plan with an ETA; with `--live`, executes via
     `cargo publish -p <crate>`. New-crate first-publishes are paced at 600s
     apart to stay well under the crates.io ~10-min new-crate limit.

Resume safety: the version-already-published check makes re-runs idempotent.
If a publish fails partway through, fix and re-run.

Usage:
  python3 tools/release.py             # dry run (default)
  python3 tools/release.py --live      # actually publish
  python3 tools/release.py --live -y   # skip the confirmation prompt
  python3 tools/release.py --crate ism-data --live  # narrow to one crate
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
import time
import tomllib
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PUBLISHED_TOML = ROOT / "tools" / "published.toml"
WORKSPACE_TOML = ROOT / "Cargo.toml"

# crates.io enforces ~1 new-crate publish per 10 min per user. 600s is
# a defensive floor; bump if you start hitting 429s.
NEW_CRATE_PAUSE_SECONDS = 600
USER_AGENT = "ism-data-release/1.0 (+https://github.com/marquetools/ism-data)"
HTTP_TIMEOUT_SECONDS = 30


# --- types ------------------------------------------------------------------


@dataclass
class CratePlan:
    cargo_name: str  # e.g. "ism-ismcat" — what cargo publish -p uses
    upstream_pkg: str | None  # ODNI package name; None for the meta crate
    is_meta: bool
    state: str  # "new" | "needs-version" | "already-published" | "unknown"
    existing_versions: list[str]


# --- config loading ---------------------------------------------------------


def load_published() -> dict:
    if not PUBLISHED_TOML.exists():
        sys.exit(f"missing {PUBLISHED_TOML}")
    with open(PUBLISHED_TOML, "rb") as fh:
        return tomllib.load(fh)


WORKSPACE_VERSION_RE = re.compile(
    r'^\s*version\s*=\s*"([^"]+)"', re.MULTILINE
)


def workspace_version() -> str:
    """Parse `[workspace.package].version` out of the root Cargo.toml.

    Avoids a TOML write-back roundtrip; we only need to read.
    """
    src = WORKSPACE_TOML.read_text(encoding="utf-8")
    # First version = under [workspace.package] (only one in our root Cargo.toml).
    m = WORKSPACE_VERSION_RE.search(src)
    if not m:
        sys.exit("could not find workspace.package.version in root Cargo.toml")
    return m.group(1)


def crate_name_for_pkg(pkg: str) -> str:
    return "ism-" + pkg.lower()


# --- crates.io probing -------------------------------------------------------


def fetch_crate_versions(cargo_name: str) -> list[str] | None:
    """Return a list of version strings published to crates.io for this
    crate, or None if the crate has never been published (404)."""
    url = f"https://crates.io/api/v1/crates/{cargo_name}"
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(req, timeout=HTTP_TIMEOUT_SECONDS) as resp:
            payload = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raise
    versions = payload.get("versions") or []
    return [v["num"] for v in versions if "num" in v]


def classify(cargo_name: str, target_version: str) -> tuple[str, list[str]]:
    """Return (state, existing_versions)."""
    versions = fetch_crate_versions(cargo_name)
    if versions is None:
        return "new", []
    if target_version in versions:
        return "already-published", versions
    return "needs-version", versions


# --- planning ---------------------------------------------------------------


def build_plan(cfg: dict, version: str, only: list[str] | None) -> list[CratePlan]:
    plans: list[CratePlan] = []

    # Meta crate first — it's the discovery surface; if anything depends on a
    # specific meta version it should land before per-package releases.
    for meta_name in sorted(cfg.get("meta", {}).keys()):
        if only and meta_name not in only:
            continue
        state, existing = classify(meta_name, version)
        plans.append(
            CratePlan(
                cargo_name=meta_name,
                upstream_pkg=None,
                is_meta=True,
                state=state,
                existing_versions=existing,
            )
        )

    for pkg in sorted(cfg.get("packages", {}).keys()):
        cargo_name = crate_name_for_pkg(pkg)
        if only and cargo_name not in only and pkg not in only:
            continue
        state, existing = classify(cargo_name, version)
        plans.append(
            CratePlan(
                cargo_name=cargo_name,
                upstream_pkg=pkg,
                is_meta=False,
                state=state,
                existing_versions=existing,
            )
        )

    return plans


def estimate_total_seconds(plans: list[CratePlan]) -> int:
    new_count = sum(1 for p in plans if p.state == "new")
    update_count = sum(1 for p in plans if p.state == "needs-version")
    if new_count + update_count == 0:
        return 0
    # First new-crate publish doesn't pre-wait; subsequent ones each wait.
    # Add a small fudge for cargo publish itself (registry index propagation).
    inter_pauses = max(0, new_count - 1) * NEW_CRATE_PAUSE_SECONDS
    cargo_overhead = (new_count + update_count) * 30
    return inter_pauses + cargo_overhead


def print_plan(plans: list[CratePlan], version: str) -> None:
    print(f"workspace.package.version = {version}")
    print(f"crates.io publish plan ({len(plans)} crate(s)):\n")
    for p in plans:
        marker = {
            "new": "🆕",
            "needs-version": "↑",
            "already-published": "✓",
            "unknown": "?",
        }.get(p.state, "?")
        suffix = ""
        if p.state == "needs-version":
            latest = p.existing_versions[0] if p.existing_versions else "?"
            suffix = f"  (latest: {latest})"
        elif p.state == "already-published":
            suffix = "  (skip)"
        print(f"  {marker}  {p.cargo_name}{suffix}")
    eta = estimate_total_seconds(plans)
    new_count = sum(1 for p in plans if p.state == "new")
    update_count = sum(1 for p in plans if p.state == "needs-version")
    skipped = sum(1 for p in plans if p.state == "already-published")
    if new_count + update_count == 0:
        print(f"\nNothing to do — all {skipped} crate(s) already at {version}.")
    elif new_count > 1:
        print(
            f"\nEstimated wall time: ~{max(1, eta // 60)} min "
            f"({new_count} new crate(s) paced at {NEW_CRATE_PAUSE_SECONDS}s "
            f"between first-publishes; crates.io rate limit)"
        )
    elif new_count == 1:
        print(
            f"\nEstimated wall time: ~1 min "
            f"(1 new crate; rate limit only kicks in for the 2nd onward)"
        )
    else:
        print(
            f"\nEstimated wall time: ~1 min "
            f"({update_count} version bump(s); no rate-limit waits)"
        )


# --- execution --------------------------------------------------------------


def run_cargo_publish(cargo_name: str, dry: bool) -> None:
    cmd = ["cargo", "publish", "-p", cargo_name]
    if dry:
        cmd.append("--dry-run")
    print(f"\n$ {' '.join(cmd)}", flush=True)
    try:
        subprocess.run(cmd, check=True, cwd=ROOT)
    except subprocess.CalledProcessError as e:
        sys.exit(
            f"\ncargo publish failed for {cargo_name} (exit {e.returncode}). "
            f"Fix the issue, then re-run release.py — already-published crates "
            f"will be skipped automatically."
        )


def execute_plan(plans: list[CratePlan]) -> None:
    todo = [p for p in plans if p.state in ("new", "needs-version")]
    new_remaining = sum(1 for p in todo if p.state == "new")

    for p in todo:
        run_cargo_publish(p.cargo_name, dry=False)
        if p.state == "new":
            new_remaining -= 1
            if new_remaining > 0:
                print(
                    f"\nWaiting {NEW_CRATE_PAUSE_SECONDS}s before next "
                    f"new-crate first-publish (crates.io rate limit). "
                    f"{new_remaining} new-crate(s) remaining.",
                    flush=True,
                )
                time.sleep(NEW_CRATE_PAUSE_SECONDS)


# --- main -------------------------------------------------------------------


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--live",
        action="store_true",
        help="actually publish (default is dry-run: prints plan only)",
    )
    ap.add_argument(
        "-y",
        "--yes",
        action="store_true",
        help="skip the confirmation prompt (use with --live)",
    )
    ap.add_argument(
        "--crate",
        action="append",
        default=[],
        help="restrict to specific crate(s); repeatable. Accepts cargo name "
        "(ism-ismcat) or upstream package name (ISMCAT)",
    )
    ap.add_argument(
        "--cargo-dry-run",
        action="store_true",
        help="run `cargo publish --dry-run` for each crate as a pre-check",
    )
    args = ap.parse_args()

    cfg = load_published()
    version = workspace_version()
    only = args.crate or None
    plans = build_plan(cfg, version, only)

    if not plans:
        if only:
            sys.exit(
                f"no crates matched --crate {only}. Check tools/published.toml."
            )
        print(
            "Nothing to publish: tools/published.toml has no entries.\n"
            "Add a [packages] entry first."
        )
        return 0

    print_plan(plans, version)

    if args.cargo_dry_run:
        print("\n--- cargo publish --dry-run pre-check ---")
        for p in plans:
            if p.state == "already-published":
                continue
            run_cargo_publish(p.cargo_name, dry=True)

    if not args.live:
        print("\nDry run only. Re-run with --live to publish.")
        return 0

    if not args.yes:
        eta = estimate_total_seconds(plans)
        prompt = "\nProceed with --live publish?"
        if eta:
            prompt += f" (~{eta // 60} min)"
        prompt += " [y/N] "
        ans = input(prompt).strip().lower()
        if ans not in ("y", "yes"):
            print("aborted")
            return 1

    execute_plan(plans)
    print("\nDone.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
