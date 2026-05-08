<!--
SPDX-License-Identifier: MIT-0 OR Unlicense
-->

# ism-data

Metadata-only meta-crate for the ODNI public XML schema set. Carries no
data files. Use this crate to:

- Enumerate the ODNI packages shipped by this workspace (`PACKAGES`).
- Look up which package declares a given XML namespace
  (`package_for_namespace`, `resolve_namespace`).

Part of the [`ism-data`](https://github.com/marquetools/ism-data)
workspace. Each ODNI package lives in its own `ism-{pkg}` crate.

## Use

```toml
[build-dependencies]
ism-data    = { git = "https://github.com/marquetools/ism-data", tag = "v..." }
ism-ismcat  = { git = "https://github.com/marquetools/ism-data", tag = "v..." }
```

```rust
// build.rs
fn main() {
    let (pkg, rel) = ism_data::resolve_namespace("urn:schema:guide:schema:ismcat")
        .expect("ISMCAT schema-guide namespace is part of the ODNI set");
    // pkg = "ISMCAT", rel = "Schema/ISMCAT/SchemaGuideSchema.xsd"

    // Combine with the per-package crate's data:
    let path = ism_ismcat::package_root().join(rel);
    println!("cargo:rerun-if-changed={}", path.display());
    // ... pass to your codegen
}
```

## License

Crate scaffolding: MIT-0 OR Unlicense. Schemas (in the per-package
crates): U.S. Government public-domain works.
