---
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
- [ ] Run `tools/rederive_manifest.py` and inspect the resulting `manifest.txt`
- [ ] Recompute the manifest digest; record as the new `MANIFEST_DIGEST`
- [ ] Generate the new `provenance.toml` with all 58 (or however many) upstream zip hashes

### Update crate metadata

- [ ] Bump `version` in `Cargo.toml` to the new ODNI snapshot date
- [ ] Replace `data/` with the new materialized tree
- [ ] Replace `data/_provenance/manifest.txt`
- [ ] Replace `data/_provenance/manifest.sha256`
- [ ] Update `MANIFEST_DIGEST` const in `src/lib.rs`
- [ ] Replace `data/_provenance/provenance.toml`
- [ ] Update `tools/upstream_baseline.json` with new URLs / Last-Modified / Content-Length

### Verify

- [ ] `cargo check` passes (build.rs verifies the new manifest)
- [ ] `cargo test` passes
- [ ] `cargo test -- --ignored verify_full_tree` passes
- [ ] Trigger `reproduce-from-zips` workflow; confirm match
- [ ] Diff `data/_provenance/manifest.txt` against previous snapshot; spot-check the moves

### Release

- [ ] Open PR; require 2-person review on `data/` changes
- [ ] Merge to `main`
- [ ] Create signed git tag (`git tag -s vYYYY.M.D`)
- [ ] Push tag; verify workflows pass on the tag
- [ ] Cut a GitHub Release; attach the upstream zips as release assets

### Downstream rollout

- [ ] Bump `odni-schemas` rev/tag in Marque's `Cargo.toml`
- [ ] Spot-check Marque's codegen output for unexpected diffs
- [ ] Run Marque's full test suite against the new schemas
- [ ] Merge Marque PR

## Notes

(Anything reviewers should know about this re-vendor — new packages,
removed packages, breaking changes in upstream namespaces, etc.)
