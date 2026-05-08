# Provenance

Per-crate tamper-evidence for the `data/` slice carried by this crate.

`manifest.txt`
:   SHA-256 of every file under `data/` (excluding this directory),
    sorted, format `<sha256-hex>  <relpath>`. The crate's `build.rs`
    hashes every file at consumer compile time and refuses to compile
    if any line in this manifest doesn't match.

`manifest.sha256`
:   SHA-256 of `manifest.txt` itself. Also baked into `MANIFEST_DIGEST`
    in `src/lib.rs` so external consumers can pin the digest in release
    notes / signed tags.
