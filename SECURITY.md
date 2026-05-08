<!--
SPDX-License-Identifier: MIT-0 OR Unlicense
-->

# Security model for `ism-data`

The `ism-*` crates in this workspace are consumed at *build time* by
Marque (and any other Rust project doing codegen from ODNI schemas).
If a tampered XSD slips into that path, codegen produces backdoored
Rust that mishandles classification markings, audit metadata, and
access controls. The blast radius is broad, so the crates are
hardened on multiple layers.

## Threat model

The threats below are listed roughly by likelihood. The mitigations
column tells you whether the workspace handles it, the consumer needs
to handle it, or both.

| # | Threat | Mitigated by |
|---|--------|--------------|
| 1 | Files in the cargo cache (`~/.cargo/git/checkouts/.../ism-data-*/crates/ism-<pkg>/data/`) are tampered with locally before consumer build. | **Per-package crate**: `build.rs` re-hashes every file in its `data/` against the baked manifest at consumer compile time. Mismatch ⇒ build fails. |
| 2 | The consumer's `cargo fetch` is MITM'd. | **Git**: commit hash verification on transfer. **Consumer**: pin to a specific commit SHA in `Cargo.toml`, not a movable tag. Commit `Cargo.lock`. |
| 3 | The `ism-data` repo is force-pushed to with a malicious commit (knitli GitHub compromise). | **Consumer**: pin to commit SHA, review diffs before bumping. **Workspace maintainers**: sign release tags (GPG or Sigstore), require 2-person review on any `crates/*/data/` PR. |
| 4 | The upstream ODNI `*-Public-Standalone.zip` is replaced with a malicious zip. | **Workspace**: `provenance.toml` at the repo root records SHA-256 of every consumed zip. Cross-check against any published ODNI hashes. |
| 5 | A future `build.rs` change introduces a malicious build-time side effect (network call, file write outside `OUT_DIR`, etc.). | **Consumer**: review PRs before bumping any per-package crate. The current `build.rs` template does only file reads inside its own `data/`. |
| 6 | Consumer uses stale schemas; new ODNI rules go un-enforced. | **Consumer**: subscribe to upstream ODNI release announcements, schedule re-vendor cadence. The `check-upstream` workflow opens an issue automatically. |
| 7 | Compile-time RCE via a malicious dependency. | **Workspace**: minimal deps — only `sha2` from RustCrypto, declared once in `[workspace.dependencies]` and used only by the per-package crates. The meta crate `ism-data` is dependency-free. |

## What the workspace guarantees

- Every file under `crates/ism-<pkg>/data/` has its SHA-256 recorded
  in that crate's `data/_provenance/manifest.txt`.
- Each per-package crate's `build.rs` (always-on by default) refuses
  to compile if any file's hash doesn't match the manifest.
- Each manifest is itself hashed: `manifest.sha256` carries the
  digest, and the `MANIFEST_DIGEST` const in each crate's `lib.rs`
  carries the same value. If a manifest is tampered with on-disk, the
  build also fails.
- The per-package crate API surface is small: a handful of pure path
  helpers and two integrity functions. No I/O on path-helper calls,
  no lazy initialisation, no global state.
- The meta crate `ism-data` has no runtime dependencies and carries no
  data — it is impossible to use it to deliver a tampered XSD because
  it doesn't ship XSDs.

## What the workspace does NOT guarantee

- That the upstream ODNI files were correct in the first place. The
  workspace proves that what's on your disk matches what was vendored.
  It cannot prove that what was vendored matches what ODNI intended.
  Cross-check `provenance.toml` against any official hashes when
  available.
- That a malicious actor with commit access to this repo cannot
  publish tampered crates. Defenses there are operational: signed
  tags, protected branches, mandatory reviews. See **Operational
  recommendations** below.

## Recommended consumer hardening (Marque)

These are the things to do at the consumer side. The workspace cannot
do them for you.

1. **Pin to commit SHA, not tag.** Tags are mutable; commit hashes
   aren't.

   ```toml
   [build-dependencies]
   ism-data    = { git = "https://github.com/marquetools/ism-data", rev = "abc123def456..." }
   ism-ismcat  = { git = "https://github.com/marquetools/ism-data", rev = "abc123def456..." }
   ```

2. **Commit `Cargo.lock`**. Cargo records the resolved commit hash
   for every git dep in the lockfile. Committing it means subsequent
   builds verify against that hash. Without `Cargo.lock`, a `git`
   dep can drift even with a commit pin if Cargo's resolver decides
   otherwise.

3. **Re-run `verify_integrity()` in CI.** Cheap insurance:

   ```rust
   // tests/integrity.rs
   #[test]
   fn schemas_intact() {
       ism_ismcat::verify_integrity().expect("ISMCAT schemas intact");
       ism_ic_edh::verify_integrity().expect("IC-EDH schemas intact");
       // ... one per per-package crate you depend on
   }
   ```

4. **Don't disable `verify-on-build` lightly.** The default feature is
   on for a reason. If you turn it off in CI for speed, document
   *which* CI step compensates. Don't disable it in dev.

5. **Audit upstream `MANIFEST_DIGEST` changes.** When you bump a
   per-package crate's rev, its `MANIFEST_DIGEST` will change.
   Spot-check the diff in that crate's `data/_provenance/manifest.txt`
   so you understand what moved. A re-vendor of the same upstream
   zip should produce a bit-for-bit identical manifest — if it
   doesn't, something is off.

6. **Compile in a sandboxed environment when bumping any per-package
   crate.** A compromised `build.rs` can run arbitrary code during
   `cargo build`. Review new commits, then build first in CI
   (preferably in a container or VM with no secrets), not on a
   developer machine.

## Recommended workspace-maintenance hardening

For knitli when maintaining this workspace:

1. **Sign release tags** (`git tag -s vX.Y.Z`). Establish that signing
   key out of band so consumers can verify it.
2. **Protect the default branch.** Require PRs and at least one review
   for any change to any `crates/*/data/`, `crates/*/build.rs`, or the
   meta crate.
3. **CI builds reject manifest skew.** The integrity workflow runs
   `tools/rederive_manifest.py` and fails if any per-crate manifest
   differs from data/ on disk. The reproduce-from-zips workflow goes
   further: it re-runs the consolidation against the input zips and
   fails if any per-crate derived manifest differs from the committed
   one.
4. **Use `cargo vet` or `cargo crev`** to track that dependent crates
   (`sha2`) have been audited, and to make audits reusable.
5. **Avoid adding new dependencies** unless they're widely audited.
   Each dep is a new place a `build.rs` RCE can come from. The meta
   crate stays dependency-free; per-package crates depend only on
   `sha2`.

## Reporting issues

Report security issues privately to `security@knitli.com`. Do not file
public GitHub issues for vulnerabilities. We aim to acknowledge within
72 hours and to ship a fix for confirmed issues within 14 days, with
coordinated disclosure for upstream-affecting bugs.
