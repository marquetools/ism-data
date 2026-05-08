<!--
SPDX-License-Identifier: MIT-0 OR Unlicense
-->

# ism-pm

Vendored ODNI **PM** schema package, with SHA-256 integrity verification
at compile time.

Part of the [`ism-data`](https://github.com/marquetools/ism-data) workspace.

## Use

```toml
# Cargo.toml
[build-dependencies]
ism-pm = { git = "https://github.com/marquetools/ism-data", tag = "v..." }
```

```rust,ignore
// build.rs
let xsd = ism_pm::package_root().join("Schema/PM/PM.xsd");
println!("cargo:rerun-if-changed={}", xsd.display());
// ... pass to your codegen
```

## Integrity

`build.rs` re-hashes every file under `data/` against the baked
`data/_provenance/manifest.txt` at the consumer's compile time. A single
modified byte refuses the build.

The `MANIFEST_DIGEST` const exposes the SHA-256 of the manifest itself —
pin it in your release notes for external attestation.

## License

Schemas: U.S. Government public-domain works.
Crate scaffolding: MIT-0 OR Unlicense.
