<!--
SPDX-License-Identifier: MIT-0 OR Unlicense
-->

# ism-data

Vendored ODNI public XML schemas, deduplicated and consolidated, split
into one crate per ODNI package. Designed to be consumed as
`[build-dependencies]` by Rust projects that codegen Rust types from
the ODNI XSDs (e.g. [Marque](https://github.com/marquetools/marque)).

The workspace ships **59 ODNI packages** (~700 MB of schemas,
schematron, XSL, and supporting docs) split across 59 per-package
crates plus a metadata-only meta-crate.

## Layout

```text
ism-data/                          (workspace root)
  Cargo.toml                       ← virtual workspace
  README.md
  SECURITY.md                      ← threat model + consumer hardening
  provenance.toml                  ← upstream ODNI snapshot info + zip hashes
  crates/
    ism-data/                      ← metadata-only meta crate
      Cargo.toml
      src/lib.rs                   ← PACKAGES list + namespace registry
    ism-ismcat/                    ← one crate per ODNI package
      Cargo.toml
      build.rs                     ← verifies its data/ slice at compile time
      src/lib.rs                   ← package API
      data/                        ← ISMCAT files only
        ISMCAT/...
        _provenance/
          manifest.txt             ← SHA-256 of every file under data/
          manifest.sha256          ← SHA-256 of manifest.txt itself
    ism-ic-edh/
    ism-base-tdf/
    ... (59 total per-package crates)
  tools/                           ← regen + reproduce scripts
  .github/workflows/               ← integrity + reproduce CI
```

Per-package crate names are `ism-{lowercased}`:

| ODNI package | Crate name      |
|--------------|------------------|
| ISMCAT       | `ism-ismcat`     |
| IC-Docbook   | `ism-ic-docbook` |
| BASE-TDF     | `ism-base-tdf`   |
| RR-SM        | `ism-rr-sm`      |
| RevRecall    | `ism-revrecall`  |

Within each package, the directory shape is exactly what ODNI ships in
their `*-Public-Standalone.zip`, so all relative `xs:import` /
`schemaLocation` references resolve as the schemas' authors intended.

## Consume from your project

Add only the per-package crates your codegen needs as
`[build-dependencies]`. A small allowlist of crates is published to
crates.io (see [`tools/published.toml`](tools/published.toml)); everything
else is reachable only via git dependency. To detect at runtime which
packages are crates.io-reachable, use `ism_data::is_published(pkg)`.

```toml
# crates.io (preferred when available)
[build-dependencies]
ism-data    = "20230609.0.0"
ism-ismcat  = "20230609.0.0"
ism-ic-edh  = "20230609.0.0"

# OR, git tag (any package, including those not on crates.io)
[build-dependencies]
ism-data    = { git = "https://github.com/marquetools/ism-data", tag = "v20230609.0.0" }
ism-ismcat  = { git = "https://github.com/marquetools/ism-data", tag = "v20230609.0.0" }
ism-ic-edh  = { git = "https://github.com/marquetools/ism-data", tag = "v20230609.0.0" }
```

```rust
// build.rs
fn main() {
    // Per-package crate API: get a path to a specific schema.
    let xsd = ism_ismcat::package_root().join("Schema/ISMCAT/ISMCAT.xsd");
    println!("cargo:rerun-if-changed={}", xsd.display());

    // Meta crate: resolve a namespace to (package, relpath).
    let (pkg, rel) = ism_data::resolve_namespace("urn:us:gov:ic:edh")
        .expect("IC-EDH namespace is part of the ODNI set");
    assert_eq!(pkg, "IC-EDH");
    let edh_xsd = ism_ic_edh::package_root().join(rel);

    // Pass to your codegen.
    my_codegen::generate_rust(&xsd);
    my_codegen::generate_rust(&edh_xsd);
}
```

## Per-package crate API

Every `ism-{pkg}` crate exposes:

```rust
pub const PACKAGE_NAME: &str;          // e.g. "ISMCAT"
pub const MANIFEST_DIGEST: &str;       // SHA-256 of data/_provenance/manifest.txt
pub const FILE_COUNT: usize;           // count of files under data/

pub fn data_root() -> PathBuf;         // -> .../crates/ism-ismcat/data
pub fn package_root() -> PathBuf;      // -> .../crates/ism-ismcat/data/ISMCAT
pub fn resolve_namespace(uri: &str) -> Option<PathBuf>;
pub fn known_namespaces() -> impl Iterator<Item = (&'static str, &'static str)>;

pub fn verify_integrity() -> Result<usize, VerifyError>;
pub fn verify_file(rel: &str) -> Result<(), VerifyError>;
```

`env!("CARGO_MANIFEST_DIR")` resolves at the consumer's build time to
the location where Cargo placed the per-package crate's source —
typically inside `~/.cargo/git/checkouts/` when consumed as a git
dependency. That's exactly where the data files live, so paths Just
Work.

## Meta crate API

`ism-data` (the meta crate) carries no schema files. It exposes:

```rust
pub const PACKAGES: &[&str];           // 59 ODNI package names

pub fn resolve_namespace(uri: &str) -> Option<(&'static str, &'static str)>;
pub fn package_for_namespace(uri: &str) -> Option<&'static str>;
pub fn relpath_for_namespace(uri: &str) -> Option<&'static str>;
pub fn known_namespaces() -> impl Iterator<Item = (&'static str, &'static str, &'static str)>;
pub fn crate_name_for(package: &str) -> Option<String>;  // e.g. "ISMCAT" -> "ism-ismcat"
```

## Integrity

Every per-package crate's `build.rs` re-hashes every file under its own
`data/` against `data/_provenance/manifest.txt` at the consumer's
compile time and refuses to compile on mismatch. A single modified byte
under `crates/ism-ismcat/data/` breaks any consumer's build of that
crate. See `SECURITY.md` for the full threat model.

For runtime checks, use `verify_integrity()` / `verify_file(rel)` on
the per-package crate, or `MANIFEST_DIGEST` for external attestation.

## Versioning

The workspace version (`Cargo.toml`'s `[workspace.package].version`)
tracks the date stamp of the latest ISM package in the upstream ODNI
snapshot consolidated. All per-package crates inherit it via
`version.workspace = true`. Bump it whenever you re-vendor.

## CI / automation

Three GitHub Actions workflows live under `.github/workflows/`:

- **integrity.yml** — runs on every PR and weekly. Re-derives every
  per-crate manifest from `crates/*/data/`, diffs against the committed
  manifests, runs `cargo test --workspace --all-features -- --ignored`
  (which exercises the full-tree integrity check across every crate).
  Prevents drift between any crate's `data/` and its `manifest.txt`.
- **check-upstream.yml** — weekly cron, plus manual trigger. Runs
  `tools/check_upstream.py` to HEAD-check known ODNI zip URLs and
  scrape the standards listing page; opens a tracking issue when
  changes are detected. Configure the URLs in
  `tools/upstream_baseline.json` once before this workflow becomes
  useful.
- **reproduce-from-zips.yml** — manual trigger. Given a URL to a
  bundle of the upstream zips, downloads them, verifies against
  `provenance.toml`, runs the per-package consolidation, and asserts
  every per-crate manifest matches the committed one. The strongest
  available proof that "what we vendored" came from "what ODNI
  published".

## Re-vendoring

When ODNI publishes new package versions, see
`.github/ISSUE_TEMPLATE/upstream-update.md` for the full re-vendor
checklist. The high-level flow:

1. Download the new `*-Public-Standalone.zip` files.
2. Run the consolidation script (lives in the parent project at
   `_meta/consolidate.py`) to produce a deduplicated tree.
3. Move the tree under `crates/ism-<pkg>/data/<PKG>/` for every package.
4. Run `tools/rederive_manifest.py --write` to regenerate every
   per-crate `manifest.txt`, `manifest.sha256`, and `MANIFEST_DIGEST`.
5. Bump `[workspace.package].version` in the workspace `Cargo.toml`.
6. Update workspace `provenance.toml` with the new snapshot date and
   upstream zip hashes.
7. If new packages appear, scaffold them with
   `tools/split_into_crates.py` and add to `crates/ism-data/src/lib.rs`
   `PACKAGES` const.
8. Commit, tag, push.

## Namespaces known to the workspace

235 namespaces have a canonical-path mapping baked into the meta crate.
Iterate them all:

```rust
for (uri, pkg, rel) in ism_data::known_namespaces() {
    println!("{} -> {} / {}", uri, pkg, rel);
}
```

Namespaces from upstream standards (W3C XLink, GML, DocBook, etc.)
that happen to appear in the bundled schemas *are* present in the
table when ODNI redistributes them — those entries point at the
ODNI-bundled copy. If you need authoritative upstream behavior, point
your XML library at the appropriate upstream catalog separately.

## What's intentionally not here

- **No runtime parsing or validation.** This workspace is data + path
  helpers only. Pair it with `quick-xml`, `xmlschema`, `roxmltree`, or
  whatever XML library suits your codegen.
- **No XML catalog file.** Cargo doesn't have a clean way to surface
  static asset paths to non-Rust tools. If you need a catalog, it's
  trivial to generate one from `ism_data::known_namespaces()` at build
  time.

## Size

Compressed `git clone` of this repo runs around 50–80 MB; git's delta
compression collapses the redundant content very efficiently. The
working-tree size after clone is ~700 MB across all 59 crates. For a
workspace consumed only at build time, this is acceptable — and
consumers that publish individual crates to crates.io can ship
just the slices they need.

## License

Schemas are U.S. Government public-domain works. Crate scaffolding
(Rust source, build scripts, CI, config) is dual-licensed under MIT-0
or Unlicense. See [LICENSES/](./LICENSES) and the `LICENSE-*` files.
