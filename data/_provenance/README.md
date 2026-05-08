# Provenance

This directory carries the tamper-evidence material for the `data/` tree.

## Files

`manifest.txt`
:   SHA-256 of every file under `data/`, sorted, format
    `<sha256-hex>  <path-relative-to-data-root>`. The crate's `build.rs`
    hashes every file in `data/` at consumer compile time and refuses
    to compile if any line in this manifest doesn't match. Tampering
    with a single byte under `data/` breaks the build.

`manifest.sha256`
:   SHA-256 of `manifest.txt` itself. Bake this into release notes /
    signed git tags / external attestations so tampering with the
    manifest *and* the data is also detectable from outside.

`provenance.toml`
:   Snapshot metadata: ODNI snapshot date, manifest digest, and (when
    available) SHA-256 of the upstream `*-Public-Standalone.zip` files.
    Lets you cross-check the inputs against any hashes ODNI publishes
    alongside their downloads.

## What this protects against

- Local tampering of files in the cargo cache (`~/.cargo/git/checkouts/...`).
- Accidental file corruption.
- Some forms of MITM, in concert with git commit pinning by consumers.

## What this does NOT protect against

- A compromised odni-schemas repo where the attacker also rewrote the
  manifest. Defense: pin to a known-good commit SHA in your consumer's
  `Cargo.toml`, not a movable tag. Sign your release tags.
- A compromised upstream ODNI zip. Defense: cross-check
  `provenance.toml` zip hashes against any official published hashes.
- Compile-time RCE via a malicious `build.rs` added to this crate by an
  attacker. Defense: review the diff between the commit you pin and
  any new commit before bumping in your consumer.
