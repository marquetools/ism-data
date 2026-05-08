# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A vendored, deduplicated snapshot of ODNI public XML schemas, split across a Cargo
workspace of **59 per-package crates** (`crates/ism-<pkg>/`) plus one
**metadata-only meta crate** (`crates/ism-data/`). It is consumed as
`[build-dependencies]` by Rust projects (notably Marque) that codegen Rust types
from the ODNI XSDs. The crates ship no runtime XML logic — they are data + path
helpers + integrity verification.

## Version scheme

`[workspace.package].version` is `YYYYMMDD.MAJOR.PATCH`:

- `YYYYMMDD` — ODNI snapshot date the data tree was captured from. Drives the
  whole workspace; new ODNI publication ⇒ new YYYYMMDD, PATCH resets to 0.
- `MAJOR` — reserved, always `0` for now. Held in case we ever need a third
  axis (e.g. structural break unrelated to schema content).
- `PATCH` — tooling-revision counter. Bump for fixes to `build.rs`, integrity
  logic, generated-code shape, or the meta-crate API where the data bytes
  themselves don't change.

So `20230609.0.1` ships the same schema bytes as `20230609.0.0` but with a
build-script or codegen fix; `20240115.0.0` is a fresh snapshot.

Cargo SemVer rules apply: leading zeros are not allowed (use `2024.1.5` not
`2024.01.05` if you ever switch back to dotted-date form), and the workspace
inherits this version into every member crate via `version.workspace = true`.

## Publishing to crates.io

Most consumers can pull from git, but Marque consumers need crates.io
mirrors. The workspace ships 60 crates, but crates.io's ~10-min new-crate
rate limit makes "publish everything" both slow and unwanted, so we use an
allowlist.

Source of truth: [`tools/published.toml`](tools/published.toml). Fields:

- `[meta]` — the `ism-data` meta crate. Always published; consumers need it
  to discover packages.
- `[packages]` — per-package crates published to crates.io. Add an entry
  only when an actual consumer needs it via crates.io.

Workflow:

```bash
# 1. Edit tools/published.toml — add an entry under [packages]:
#      "ISMCAT" = { since = "20230609.0.0" }
#
# 2. Propagate the change to derived files (per-crate Cargo.toml
#    publish flag + ism-data PUBLISHED_PACKAGES slice + tests):
python3 tools/sync_published.py

# 3. Verify build is still green:
cargo check --workspace --all-features
cargo test -p ism-data

# 4. Preview the release plan (dry-run by default):
python3 tools/release.py

# 5. Pre-flight cargo's own dry-run too, optional but recommended:
python3 tools/release.py --cargo-dry-run

# 6. Publish for real (paces new crates at 600s for crates.io rate limit):
python3 tools/release.py --live
```

Idempotent: re-running `release.py` skips already-published versions, so
recovery from a partial release is just "re-run". CI can enforce drift via
`python3 tools/sync_published.py --check` (exit 1 if `published.toml` and
derived files disagree).

Ordering: meta crate publishes first, then per-package crates alphabetically.
Per-package crates have no inter-dependency, so order within them doesn't
matter.

The `ism-data` meta crate exposes `PUBLISHED_PACKAGES`, `is_published(pkg)`,
and `resolve_namespace_published(uri)` so build scripts can fail loudly when
they target a namespace whose package is git-only — useful for Marque
consumers that can only fetch from crates.io.

## Common commands

```bash
# Build / typecheck — runs each per-package crate's build.rs integrity check
cargo check --workspace --all-features

# Fast unit tests (excludes the heavy --ignored full-tree verification)
cargo test --workspace --all-features

# Heavy: full-tree SHA-256 verification of every file in every crate's data/
cargo test --workspace --all-features -- --ignored

# Run a single crate's tests
cargo test -p ism-ismcat
cargo test -p ism-ismcat --features verify-on-build -- --ignored verify_full_tree

# Confirm consumers can opt out of compile-time verification cleanly
cargo check --workspace --no-default-features

# mise tasks (defined in mise.toml)
mise run fmt        # cargo fmt --all
mise run fix        # cargo fix --workspace --all-targets --all-features --allow-dirty

# Skip per-crate build-time verification ad hoc (developer escape hatch)
ISM_DATA_SKIP_VERIFY=1 cargo check --workspace
```

`tools/` Python scripts (run from repo root):

```bash
# Walk every crate's data/, compare against the committed manifest. CI uses this.
python3 tools/rederive_manifest.py
# Same walk, but rewrite manifest.txt + manifest.sha256 + MANIFEST_DIGEST in lib.rs
python3 tools/rederive_manifest.py --write
python3 tools/rederive_manifest.py --crate ism-ismcat   # scope to one or more crates

# Scaffold per-package crates from PACKAGES + namespace table in ism-data/src/lib.rs
python3 tools/split_into_crates.py            # move data/<PKG>/ into crates/ism-<pkg>/
python3 tools/split_into_crates.py --regen    # only regenerate Cargo.toml/build.rs/lib.rs

# Reproduce per-crate manifests from upstream zips (used by reproduce-from-zips CI)
python3 tools/reproduce_from_zips.py --zips DIR --provenance provenance.toml

# Weekly canary: HEAD-check ODNI zip URLs vs tools/upstream_baseline.json
python3 tools/check_upstream.py

# Publishing (see "Publishing to crates.io" below)
python3 tools/sync_published.py               # propagate published.toml -> derived files
python3 tools/sync_published.py --check       # CI: fail if derived files drifted
python3 tools/release.py                      # dry-run publish plan
python3 tools/release.py --live               # actually publish (paced)
```

## Architecture

### Two crate kinds

- **`crates/ism-data/`** — meta crate, *no data files*, no runtime deps. Exposes
  `PACKAGES`, `resolve_namespace(uri) -> Option<(pkg, relpath)>`, and
  `crate_name_for(pkg)`. Backed by a `NAMESPACE_TO_PACKAGE` table of 235 sorted
  triples in `src/lib.rs`. **The table must stay sorted by URI** — there's a unit
  test that enforces this, and `resolve_namespace` does a binary search.
- **`crates/ism-<pkg>/`** — one per ODNI package (59 of them). Crate naming is
  `ism-{lowercased(package)}` (e.g. `ISMCAT` → `ism-ismcat`,
  `IC-Docbook` → `ism-ic-docbook`). Each ships:
  - `data/<PKG>/...` — the unzipped ODNI tree, exactly as upstream ships it so
    relative `xs:import`/`schemaLocation` references resolve as authored.
  - `data/_provenance/manifest.txt` — `<sha256>  <relpath>` line per file.
  - `data/_provenance/manifest.sha256` — SHA-256 of `manifest.txt`.
  - `src/lib.rs` — `PACKAGE_NAME`, `MANIFEST_DIGEST`, `FILE_COUNT`, path helpers
    (`data_root`, `package_root`), a per-package `NAMESPACES` table (also sorted),
    and `verify_integrity` / `verify_file`.
  - `build.rs` — re-hashes every file under `data/` against `manifest.txt` at
    consumer compile time. Refuses to compile on mismatch. Gated by the
    `verify-on-build` default feature; `ISM_DATA_SKIP_VERIFY=1` is the env escape
    hatch (build.rs prints a `cargo:warning=` when skipping).
  - The only dependency is `sha2` (declared once in `[workspace.dependencies]`).

### Integrity chain (treat as load-bearing)

```
data/<file>          —SHA-256→  manifest.txt entry
manifest.txt         —SHA-256→  manifest.sha256
manifest.sha256       ==        MANIFEST_DIGEST const in src/lib.rs
                                                    ↑
                          enforced by integrity.yml CI step
```

Anything that mutates a file under `crates/*/data/` (other than `_provenance/`)
**must** be followed by `tools/rederive_manifest.py --write`, which rewrites all
three of `manifest.txt`, `manifest.sha256`, and the `MANIFEST_DIGEST` const in
`src/lib.rs`. Skipping any of them breaks the build, and CI catches the drift.

### Path resolution

`env!("CARGO_MANIFEST_DIR")` resolves at the consumer's compile time to where
Cargo placed each per-package crate's source (typically
`~/.cargo/git/checkouts/...`). All path helpers (`data_root`, `package_root`,
`resolve_namespace`) build on top of that, so consumers get filesystem paths that
"just work" without runtime configuration.

### Namespace resolution flow for consumers

```
ism_data::resolve_namespace("urn:us:gov:ic:edh")  →  ("IC-EDH", "Schema/IC-EDH/IC-EDH.xsd")
ism_ic_edh::package_root().join(rel)              →  absolute filesystem path
```

The meta crate's `relpath` is *within* a package (no `<PKG>/` prefix). The
per-package crate's `NAMESPACES` table stores the relpath *under the crate's
`data/`* (with the `<PKG>/` prefix included). They are two different conventions
— don't conflate them.

## Re-vendoring (when ODNI publishes new schemas)

The full checklist lives in `.github/ISSUE_TEMPLATE/upstream-update.md`. The flow:

1. Download new `*-Public-Standalone.zip` files; hash each one.
2. Run external consolidation pipeline (lives outside this repo) to produce
   deduplicated trees per package.
3. Move each tree under `crates/ism-<pkg>/data/<PKG>/`.
4. `tools/rederive_manifest.py --write`.
5. Bump `[workspace.package].version` to the new snapshot date.
6. Update `provenance.toml` (snapshot date + zip hashes — the current file notes
   that initial-vendor zip hashes were lost; the next vendor must record them).
7. New packages: scaffold with `tools/split_into_crates.py`, add to
   `crates/ism-data/src/lib.rs` `PACKAGES`, regenerate namespace tables.
8. Verify: `cargo check`, `cargo test`, `cargo test -- --ignored`, then
   trigger `reproduce-from-zips` CI.

## CI workflows

- **`integrity.yml`** — every PR + weekly Monday cron. Verifies manifest digest
  consistency, re-derives manifests from `data/`, asserts `MANIFEST_DIGEST`
  consts match `manifest.sha256`, then runs `cargo check`/`test` workspace-wide
  including `--ignored`. Also confirms `--no-default-features` builds cleanly.
- **`check-upstream.yml`** — weekly cron + manual. Runs `tools/check_upstream.py`
  against `tools/upstream_baseline.json` (which needs to be populated once before
  this becomes useful) and opens a tracking issue when zip URLs move.
- **`reproduce-from-zips.yml`** — manual. Given a URL bundle of upstream zips,
  re-runs the full reproduction pipeline and asserts every per-crate manifest
  matches the committed one.

## Conventions specific to this repo

- **Per-crate `NAMESPACES` table** *and* the meta crate's `NAMESPACE_TO_PACKAGE`
  table are sorted by URI; both have unit tests enforcing this. Inserts must keep
  the order.
- **Never edit `manifest.txt` / `manifest.sha256` / `MANIFEST_DIGEST` by hand.**
  Always go through `tools/rederive_manifest.py --write` so all three stay in
  sync.
- **Never edit per-crate `publish` fields or `PUBLISHED_PACKAGES` by hand.**
  Edit `tools/published.toml` and run `tools/sync_published.py`. The marker
  block in `crates/ism-data/src/lib.rs` and the per-crate `publish = true`
  lines are derived state.
- **`build.rs` is intentionally minimal** and reads only inside its own `data/`.
  Adding any side effect (network, writes outside `OUT_DIR`, env probing beyond
  `ISM_DATA_SKIP_VERIFY`) is a security regression — see SECURITY.md, threat #5.
- **Don't add dependencies casually.** Per-package crates use `sha2` only; the
  meta crate has zero deps. New deps expand the build-time RCE surface for every
  downstream consumer.
- **Workspace uses `resolver = "3"` and `edition = "2024"`.** All per-package
  crates inherit `version`, `edition`, `license`, `repository` from
  `[workspace.package]` via `field.workspace = true`.
- **License**: schemas are U.S. Government public-domain; crate scaffolding is
  dual-licensed `MIT-0 OR Unlicense`. New source files need an
  `SPDX-License-Identifier: MIT-0 OR Unlicense` header. The repo is REUSE-compliant
  (`REUSE.toml`, `LICENSES/`, `mise.toml` pins `pipx:reuse`).
