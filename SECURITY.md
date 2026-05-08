# Security model for `odni-schemas`

This crate is consumed at *build time* by Marque (and any other Rust
project doing codegen from ODNI schemas). If a tampered XSD slips into
that path, codegen produces backdoored Rust that mishandles classification
markings, audit metadata, and access controls. The blast radius is broad,
so the crate is hardened on multiple layers.

## Threat model

The threats below are listed roughly by likelihood. The mitigations
column tells you whether the crate handles it, the consumer needs to
handle it, or both.

| # | Threat | Mitigated by |
|---|--------|--------------|
| 1 | Files in the cargo cache (`~/.cargo/git/checkouts/.../odni-schemas-*/data/`) are tampered with locally before consumer build. | **Crate**: `build.rs` re-hashes every file against the baked manifest at consumer compile time. Mismatch ⇒ build fails. |
| 2 | The consumer's `cargo fetch` is MITM'd. | **Git**: commit hash verification on transfer. **Consumer**: pin to a specific commit SHA in `Cargo.toml`, not a movable tag. Commit `Cargo.lock`. |
| 3 | The `odni-schemas` repo is force-pushed to with a malicious commit (knitli GitHub compromise). | **Consumer**: pin to commit SHA, review diffs before bumping. **Crate maintainers**: sign release tags (GPG or Sigstore), require 2-person review on `data/` PRs. |
| 4 | The upstream ODNI `*-Public-Standalone.zip` is replaced with a malicious zip. | **Crate**: `data/_provenance/provenance.toml` records SHA-256 of every consumed zip. Cross-check against any published ODNI hashes. |
| 5 | A future `build.rs` change introduces a malicious build-time side effect (network call, file write outside `OUT_DIR`, etc.). | **Consumer**: review PRs before bumping the dep. Run `cargo build` of new versions in a sandboxed CI first. The current `build.rs` does only file reads inside `data/`. |
| 6 | Consumer uses stale schemas; new ODNI rules go un-enforced. | **Consumer**: subscribe to upstream ODNI release announcements, schedule re-vendor cadence. |
| 7 | Compile-time RCE via a malicious dependency of `odni-schemas`. | **Crate**: minimal deps — only `sha2` from RustCrypto. |

## What the crate guarantees

- Every file under `data/` has its SHA-256 recorded in
  `data/_provenance/manifest.txt`.
- The crate's `build.rs` (always-on by default) refuses to compile if
  any file's hash doesn't match the manifest.
- The manifest itself is hashed; `data/_provenance/manifest.sha256`
  carries the digest, and `MANIFEST_DIGEST` in `lib.rs` carries the
  same value as a `const &str`. If the manifest is tampered with
  on-disk, the build also fails.
- The `lib.rs` API surface is tiny: four pure path helpers and two
  integrity functions. No I/O on path-helper calls, no lazy
  initialisation, no global state.
- No runtime dependencies beyond `sha2` (RustCrypto).

## What the crate does NOT guarantee

- That the upstream ODNI files were correct in the first place. The
  crate proves that what's on your disk matches what was vendored. It
  cannot prove that what was vendored matches what ODNI intended. Cross-
  check `provenance.toml` against any official hashes when available.
- That a malicious actor with commit access to this repo cannot publish
  a tampered crate. Defenses there are operational: signed tags,
  protected branches, mandatory reviews. See **Operational
  recommendations** below.

## Recommended consumer hardening (Marque)

These are the things to do at the consumer side. The crate cannot do
them for you.

1. **Pin to commit SHA, not tag.** Tags are mutable; commit hashes
   aren't.

   ```toml
   [build-dependencies]
   odni-schemas = { git = "https://github.com/knitli/odni-schemas", rev = "abc123def456..." }
   ```

2. **Commit `Cargo.lock`**. Cargo records the resolved commit hash for
   every git dep in the lockfile. Committing it means subsequent
   builds verify against that hash. Without `Cargo.lock`, a `git`
   dep can drift even with a commit pin if Cargo's resolver decides
   otherwise.

3. **Re-run `verify_integrity()` in CI.** Cheap insurance:

   ```rust
   // tests/integrity.rs
   #[test]
   fn schemas_intact() {
       odni_schemas::verify_integrity().expect("ODNI schemas intact");
   }
   ```

4. **Don't disable `verify-on-build` lightly.** The default feature is
   on for a reason. If you turn it off in CI for speed, document
   *which* CI step compensates. Don't disable it in dev.

5. **Audit upstream `MANIFEST_DIGEST` changes.** When you bump the
   `odni-schemas` rev, `MANIFEST_DIGEST` will change. Spot-check the
   diff in `data/_provenance/manifest.txt` so you understand what
   moved. A re-vendor of the same upstream zips should produce a
   bit-for-bit identical manifest — if it doesn't, something is off.

6. **Compile in a sandboxed environment when bumping the dep.** A
   compromised `build.rs` can run arbitrary code during `cargo build`.
   Review new commits, then build first in CI (preferably in a
   container or VM with no secrets), not on a developer machine.

## Recommended crate-maintenance hardening

For knitli when maintaining this crate:

1. **Sign release tags** (`git tag -s vX.Y.Z`). Establish that signing
   key out of band so consumers can verify it.
2. **Protect the default branch.** Require PRs and at least one review
   for any change to `data/` or `build.rs`.
3. **CI builds reject manifest skew.** A CI job re-runs the
   consolidation against the input zips and fails if the resulting
   manifest differs from the one in the PR.
4. **Use `cargo vet` or `cargo crev`** to track that dependent crates
   (`sha2`) have been audited, and to make audits reusable.
5. **Avoid adding new dependencies** unless they're widely audited.
   Each dep is a new place a `build.rs` RCE can come from.

## Reporting issues

Report security issues privately to `security@knitli.com`. Do not file
public GitHub issues for vulnerabilities. We aim to acknowledge within
72 hours and to ship a fix for confirmed issues within 14 days, with
coordinated disclosure for upstream-affecting bugs.
