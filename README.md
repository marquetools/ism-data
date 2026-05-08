<!--
SPDX-License-Identifier: MIT-0 OR Unlicense
-->

# ism-data

Vendored ODNI public XML schemas, enums, and specs, deduplicated and consolidated. Designed
to be consumed as a `[build-dependencies]` entry by Rust projects that
codegen Rust types from the ODNI XSDs (e.g. [Marque](https://github.com/marquetools/marque))

The crate ships **58 ODNI packages** (596 MB of schemas, schematron, XSL,
and supporting docs) under `data/`, plus a small Rust API that exposes
their on-disk locations to your `build.rs`.

## Design

The crate has one transitive dependency (`sha2` from RustCrypto, used
for integrity verification). Its entire job is:

1. Carry the schema files as part of the package source, materialized
   (no symlinks) so they work the same on every OS.
2. Expose small helper functions so consumers don't have to hard-code
   paths or parse JSON in their build scripts:
   - `data_root()` — `PathBuf` to the `data/` directory.
   - `package(name)` — `PathBuf` to a specific ODNI package directory.
   - `resolve_namespace(uri)` — `Option<PathBuf>` to the canonical XSD
     that declares a given XML namespace.
   - `verify_integrity()` / `verify_file(rel)` — runtime SHA-256 checks.
3. Verify integrity at the *consumer's* compile time. The crate's
   `build.rs` (always-on by default) re-hashes every file under `data/`
   against `data/_provenance/manifest.txt` and refuses to compile on
   mismatch. See `SECURITY.md` for the full threat model.
4. Expose `PACKAGES` (58 names) and `MANIFEST_DIGEST` consts for
   compile-time use.

`env!("CARGO_MANIFEST_DIR")` resolves at the consumer's build time to
the location where Cargo placed this crate's source — typically inside
`~/.cargo/git/checkouts/` when consumed as a git dependency. That's
exactly where the data files live, so paths Just Work.

## Consume from your project

The package is way too large to publish on crates.io, you can add it with:

```toml
# Cargo.toml
[build-dependencies]
odni-schemas = { git = "https://github.com/marquetools/ism-data", tag = "v2023.06.09" }
```

```rust
// build.rs
fn main() {
    // Locate a specific schema
    let ismcat = ism_data::package("ISMCAT");
    let xsd = ismcat.join("Schema/ISMCAT/ISMCAT.xsd");
    println!("cargo:rerun-if-changed={}", xsd.display());

    // Or resolve by namespace URI
    let common = odni_schemas::resolve_namespace("urn:us:gov:ic:common")
        .expect("IC-Common namespace is part of the ODNI set");

    // Pass to your codegen
    my_codegen::generate_rust(&xsd, /* ... */);
    my_codegen::generate_rust(&common, /* ... */);
}
```

## Layout

```
ism-data/
  Cargo.toml
  README.md
  SECURITY.md            ← threat model + consumer hardening checklist
  build.rs               ← runs SHA-256 integrity check at compile time
  src/
    lib.rs               ← API + sorted namespace lookup table + verify()
  data/                  ← ~700 MB, 14,632 files across 58 packages
    _provenance/
      manifest.txt       ← SHA-256 of every file under data/
      manifest.sha256    ← SHA-256 of manifest.txt itself
      provenance.toml    ← upstream ODNI snapshot info + zip hashes
      README.md
    ADD-ERM/  ARH/  ATOM/  ...
    AUDIT/Schema/AUDIT/IC-AUDIT.xsd
    ISMCAT/Schema/ISMCAT/ISMCAT.xsd
    ...
```

Within each package, the directory shape is exactly what ODNI ships in
their `*-Public-Standalone.zip`, so all relative `xs:import` /
`schemaLocation` references resolve as the schemas' authors intended.

## Versioning

The crate version (`Cargo.toml`'s `version`) tracks the date stamp of
the latest ISM package in the upstream ODNI snapshot that was consolidated. Bump it whenever you
re-vendor. Each package is independently versioned; in practice most get published at the same time, but there is drift between packages.

## CI / automation

Three GitHub Actions workflows live under `.github/workflows/`:

- **integrity.yml** — runs on every PR and weekly. Re-derives the
  manifest from `data/`, diffs against the committed manifest, runs
  `cargo test --all-features -- --ignored` (which exercises the
  full-tree integrity check). Prevents drift between `data/` and
  `manifest.txt`.
- **check-upstream.yml** — weekly cron, plus manual trigger. Runs
  `tools/check_upstream.py` to HEAD-check known ODNI zip URLs and
  scrape the standards listing page; opens a tracking issue when
  changes are detected. Configure the URLs in
  `tools/upstream_baseline.json` once before this workflow becomes
  useful.
- **reproduce-from-zips.yml** — manual trigger. Given a URL to a
  bundle of the upstream zips, downloads them, verifies against
  `provenance.toml`, runs the consolidation, and asserts the resulting
  manifest matches the committed one. The strongest available proof
  that "what we vendored" came from "what ODNI published".

## Re-vendoring

When ODNI publishes new package versions:

1. Drop the new `*-Public-Standalone.zip` files into a clean folder.
2. Run the consolidation script (lives in the parent project at
   `_meta/consolidate.py`) to produce a deduplicated tree.
3. Run `_meta/materialize_symlinks.sh` on the result to flatten symlinks.
4. Replace this crate's `data/` directory with the materialized tree.
5. Regenerate the namespace table in `src/lib.rs` with the script in
   `tools/regen_ns_table.py` (TODO: ship that with the crate).
6. Bump `version` in `Cargo.toml` to the new ODNI snapshot date.
7. Commit, tag, push.

## Namespaces known to the crate

228 namespaces have a canonical-path mapping baked in. Iterate them all:

```rust
for (uri, relpath) in ism_data::known_namespaces() {
    println!("{} -> {}", uri, relpath);
}
```

Namespaces from upstream standards (W3C XLink, GML, DocBook, etc.) that
happen to appear in the bundled schemas are *not* part of this table —
only the ODNI / IC namespaces are. If you need to validate documents
that pull from those upstream standards, configure your XML library
with the appropriate catalogs separately.

## What's intentionally not here

- **No runtime parsing or validation.** This crate is data + path
  helpers only. Pair it with `quick-xml`, `xmlschema`, `roxmltree`, or
  whatever XML library suits your codegen.
- **No XML catalog file.** Cargo doesn't have a clean way to surface
  static asset paths to non-Rust tools, and most codegen we've seen
  works directly off file paths. If you do need a catalog file, it's
  trivial to generate one from `known_namespaces()` at build time.
- **No upstream ODNI namespaces de-dupe.** Some ODNI packages bundle
  copies of upstream specs (DocBook, W3C). Those copies are present
  but `resolve_namespace` won't return them — by design, since you
  shouldn't be relying on a bundled copy for upstream W3C semantics.

## Size

Compressed `git clone` of this repo runs around 50–80 MB, depending on
git's pack settings — git's delta compression collapses the redundant
content very efficiently. The working-tree size after clone is
~700 MB. For a crate consumed only at build time, this is acceptable.

If the working-tree size becomes an issue (e.g. CI build minutes
dominated by clone time), the next step is splitting per-ODNI-package
into separate crates and depending on only what your codegen actually
uses.

## License

Everything in this package is published without copyright in the U.S.,
as it was released into the Public Domain. See [LICENSE](./LICENSE.md).
In that spirit, anything not in the public domain, namely the Rust src,
config files in repo root, and CI actions, are all released under the
Unlicense or MIT-0, your choice.
