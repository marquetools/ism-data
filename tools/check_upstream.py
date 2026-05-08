#!/usr/bin/env python3

# SPDX-License-Identifier: MIT-0 OR Unlicense

"""
Check whether ODNI has updated any of the standalone schema zips since
the last vendor.

ODNI doesn't publish a feed for these. The closest reliable signal is
HTTP HEAD against each zip URL: a change in `Last-Modified` or
`Content-Length` indicates the file moved. Combined with a periodic
scrape of the standards listing page (to catch entirely new packages),
this gives us a low-noise weekly canary.

ODNI URL PATTERNS
-----------------
Empirically (as of 2026), ODNI hosts the public standalone packages at:

  https://www.odni.gov/files/documents/CIO/ICEA/<location>/<filename>

where <location> follows three patterns:

  1. <Snapshot>/<PKG>/                    e.g. Dec2022/ISMCAT/ISMCAT-Public-Standalone.zip
     The "true ISIM" family: 44 packages with -Public-Standalone.zip suffix.
     <Snapshot> is the publication date of that release (Dec2022, Jan2021, ...).

  2. <NATO_codename>/                     e.g. Juliet/DELIVER-Public.zip
     The CDR (Content Discovery & Retrieval) family + WSS variants.
     NATO codenames appear to correlate with version generations:
        Golf_Hotel = generation 0/1, India = V2, Juliet = V3, ...

  3. (root)                                e.g. RR-IDPublic.zip
     Flat at ICEA root; rare, used for older standalone releases.

When ODNI publishes a new snapshot, the Dec2022/ part typically becomes
a new dated folder (Jun2024/ or similar). The listing-page scrape catches
that case; you'd then update the `_setup_steps` notes in the baseline.

USAGE
-----
  check_upstream.py [--baseline tools/upstream_baseline.json]
      Compare current upstream state against baseline. Default mode.

  check_upstream.py --populate [--baseline ...]
      One-shot: HEAD-check every URL in the baseline, write the
      observed Last-Modified and Content-Length back into the baseline
      file. Run this once after filling in URLs, then commit.

OUTPUT
------
Writes a markdown report to stdout summarizing what changed (if
anything). Exits 0 on no change, 1 on errors, 0 with non-empty
report on detected changes (the workflow keys off the report
content, not the exit code, to distinguish "changes" from "errors").

CONFIG (tools/upstream_baseline.json)
-------------------------------------
{
  "listing_urls": ["https://www.dni.gov/.../ic-technical-specifications"],
  "zips": {
    "ISMCAT-Public-Standalone.zip": {
      "url": "https://www.odni.gov/files/documents/CIO/ICEA/Dec2022/ISMCAT/ISMCAT-Public-Standalone.zip",
      "last_modified": "Wed, 01 Jun 2023 14:00:00 GMT",
      "content_length": "6815415"
    },
    ...
  }
}
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import urllib.parse
import urllib.request
from pathlib import Path

USER_AGENT = "knitli-odni-schemas-canary/1.0 (security@knitli.com)"


def http_head(url: str) -> dict[str, str]:
    req = urllib.request.Request(url, method="HEAD", headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return {k.lower(): v for k, v in resp.headers.items()}
    except Exception as e:
        return {"_error": f"{type(e).__name__}: {e}"}


def http_get_text(url: str) -> tuple[str, str]:
    """Returns (body, error). One will be empty."""
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = resp.read().decode("utf-8", errors="replace")
            return data, ""
    except Exception as e:
        return "", f"{type(e).__name__}: {e}"


def find_zip_links(html: str) -> set[str]:
    """Extract every href ending in .zip from an HTML page."""
    out = set()
    for m in re.finditer(r'href\s*=\s*"([^"]+\.zip)"', html, re.I):
        out.add(m.group(1))
    return out


def populate_baseline(cfg: dict, baseline_path: Path) -> int:
    """HEAD every configured URL and write Last-Modified/Content-Length back."""
    zips = cfg.get("zips", {})
    populated = 0
    failed: list[str] = []
    for name in sorted(zips.keys()):
        meta = zips[name]
        url = meta.get("url", "")
        if not url:
            print(f"  [skip] {name} — no URL configured", file=sys.stderr)
            continue
        headers = http_head(url)
        if "_error" in headers:
            failed.append(f"{name}: {headers['_error']}")
            print(f"  [fail] {name}: {headers['_error']}", file=sys.stderr)
            continue
        meta["last_modified"] = headers.get("last-modified", "")
        meta["content_length"] = headers.get("content-length", "")
        populated += 1
        print(f"  [ok]   {name}  Last-Modified={meta['last_modified']}", file=sys.stderr)

    baseline_path.write_text(json.dumps(cfg, indent=2) + "\n")
    print(f"\nPopulated {populated} entries; {len(failed)} failed.", file=sys.stderr)
    if failed:
        print("Failures:", file=sys.stderr)
        for f in failed:
            print(f"  {f}", file=sys.stderr)
    return 0 if not failed else 1


def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--baseline",
        type=Path,
        default=Path(__file__).resolve().parent / "upstream_baseline.json",
    )
    ap.add_argument(
        "--populate",
        action="store_true",
        help="HEAD every configured URL and write Last-Modified/Content-Length "
             "back into the baseline. One-shot setup; commit the result.",
    )
    args = ap.parse_args(argv)

    if not args.baseline.exists():
        print(f"baseline file {args.baseline} does not exist — populate it first.",
              file=sys.stderr)
        return 1

    cfg = json.loads(args.baseline.read_text())

    if args.populate:
        return populate_baseline(cfg, args.baseline)

    listing_urls = cfg.get("listing_urls", [])
    zips = cfg.get("zips", {})

    report: list[str] = []
    fatal = False

    # 1. Per-zip HEAD checks
    if zips:
        report.append("## Per-zip Last-Modified / Content-Length")
        report.append("")
        skipped: list[str] = []
        for name, meta in sorted(zips.items()):
            url = meta.get("url")
            if not url:
                skipped.append(name)
                continue
            headers = http_head(url)
            if "_error" in headers:
                report.append(f"- **{name}** ({url}): ERROR — {headers['_error']}")
                fatal = True
                continue
            cur_lm = headers.get("last-modified", "")
            cur_cl = headers.get("content-length", "")
            base_lm = meta.get("last_modified", "")
            base_cl = meta.get("content_length", "")
            if cur_lm != base_lm or cur_cl != base_cl:
                report.append(f"- **{name}**: CHANGED")
                report.append(f"    - old: `{base_lm}` / `{base_cl}` bytes")
                report.append(f"    - new: `{cur_lm}` / `{cur_cl}` bytes")
                report.append(f"    - url: {url}")

        if skipped:
            report.append("")
            report.append(f"## Skipped (no URL configured: {len(skipped)})")
            report.append("")
            for n in skipped:
                report.append(f"- {n}")

    # 2. Listing-page check
    if listing_urls:
        report.append("")
        report.append("## Listing-page diff")
        report.append("")
        baseline_zip_names = set(zips.keys())
        for url in listing_urls:
            html, err = http_get_text(url)
            if err:
                report.append(f"- {url}: ERROR — {err}")
                fatal = True
                continue
            links = find_zip_links(html)
            link_names = {urllib.parse.unquote(link.rsplit("/", 1)[-1]) for link in links}
            new = sorted(link_names - baseline_zip_names)
            removed = sorted(baseline_zip_names - link_names)
            if new:
                report.append(f"- {url}: NEW zip names: {', '.join(new)}")
            if removed:
                report.append(f"- {url}: REMOVED zip names: {', '.join(removed)}")

    # Filter the per-zip section if no changes
    has_changes = any("CHANGED" in line or "NEW zip" in line or "REMOVED zip" in line
                      for line in report)

    if not has_changes and not fatal:
        print("No upstream changes detected.")
        return 0

    if fatal:
        # write report to stderr too so workflow logs surface errors
        for line in report:
            print(line, file=sys.stderr)
        if not has_changes:
            return 1

    print("\n".join(report))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
