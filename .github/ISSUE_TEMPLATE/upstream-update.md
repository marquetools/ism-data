---
# SPDX-License-Identifier: MIT-0 OR Unlicense

name: Upstream ODNI update — re-vendor checklist
about: Use when ODNI publishes new schema zips (e.g. when the upstream-canary fires)
title: 'Re-vendor: ODNI <date> snapshot'
labels: re-vendor
---

## Re-vendor checklist

### Acquire and verify inputs

- [ ] Download the new zips from ODNI
- [ ] Hash each zip and record the SHA-256
- [ ] Cross-check zip hashes against any official ODNI-published hashes
- [ ] Save the zips to durable storage (S3 / signed Release artifact)

### Consolidate

- [ ] Run the consolidation pipeline against the new zips
- [ ] Place the consolidated tree under `crates/ism-<pkg>/data/<PKG>/`
      for every ODNI package (one crate per package)
- [ ] Run `tools/rederive_manifest.py --write` to regenerate every
      per-crate `manifest.txt`, `manifest.sha256`, and `MANIFEST_DIGEST`
      const

### Update workspace metadata

- [ ] Bump `version` in workspace `Cargo.toml` (`[workspace.package].version`)
      to the new ODNI snapshot date
- [ ] Replace `provenance.toml` at workspace root with new snapshot
      metadata + upstream zip hashes
- [ ] If new packages appear: create a new `crates/ism-<pkg>/` (use
      `tools/split_into_crates.py` to scaffold), add their names to
      `crates/ism-data/src/lib.rs` `PACKAGES` const
- [ ] If namespaces change: regenerate the namespace tables in
      `crates/ism-data/src/lib.rs` and per-package `crates/ism-*/src/lib.rs`
- [ ] Update `tools/upstream_baseline.json` with new URLs /
      Last-Modified / Content-Length

### Verify

- [ ] `cargo check --workspace --all-features` passes (every per-crate
      build.rs verifies its slice)
- [ ] `cargo test --workspace --all-features` passes
- [ ] `cargo test --workspace --all-features -- --ignored` passes
      (full-tree per-crate verification)
- [ ] Trigger `reproduce-from-zips` workflow; confirm match per package
- [ ] Diff each per-crate `manifest.txt` against previous snapshot;
      spot-check the moves

### Release

- [ ] Open PR; require 2-person review on every `crates/*/data/` change
- [ ] Merge to `main`
- [ ] Create signed git tag (`git tag -s vYYYY.M.D`)
- [ ] Push tag; verify workflows pass on the tag
- [ ] Cut a GitHub Release; attach the upstream zips as release assets

### Downstream rollout

- [ ] Bump `ism-*` crate revs/tags in Marque's `Cargo.toml`
- [ ] Spot-check Marque's codegen output for unexpected diffs
- [ ] Run Marque's full test suite against the new schemas
- [ ] Merge Marque PR

## Notes

(Anything reviewers should know about this re-vendor — new packages,
removed packages, breaking changes in upstream namespaces, etc.)
