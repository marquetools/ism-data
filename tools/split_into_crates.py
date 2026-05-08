#!/usr/bin/env python3

# SPDX-License-Identifier: MIT-0 OR Unlicense

"""
One-shot scaffolder: split data/ into per-package crates under crates/.

Reads PACKAGES and NAMESPACE_TO_PATH from the legacy src/lib.rs (or the
already-split crates/ism-data/src/lib.rs once it exists), then for each
ODNI package:

  1. Move data/<PKG>/  ->  crates/ism-<pkg>/data/<PKG>/
  2. Slice the namespace table to entries whose path starts with <PKG>/
  3. Compute per-crate manifest.txt + manifest.sha256
  4. Write Cargo.toml, build.rs, src/lib.rs for the new crate

Idempotent: re-running with crates/ already populated will skip the move
step and just regenerate the generated files.

Usage:
  tools/split_into_crates.py            # use legacy src/lib.rs as source
  tools/split_into_crates.py --regen    # don't move data, just regen files
"""
from __future__ import annotations

import argparse
import hashlib
import os
import re
import shutil
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "data"
CRATES = ROOT / "crates"
PUBLISHED_TOML = ROOT / "tools" / "published.toml"


def load_published_packages() -> set[str]:
    """Return the set of upstream ODNI package names allowlisted for crates.io.

    Reads `tools/published.toml`'s `[packages]` table. Returns an empty set if
    the file is missing — that means no per-package crates are published, only
    the meta crate (which is managed separately).
    """
    if not PUBLISHED_TOML.exists():
        return set()
    with open(PUBLISHED_TOML, "rb") as fh:
        data = tomllib.load(fh)
    return set(data.get("packages", {}).keys())

# --- name conversion --------------------------------------------------------

def crate_name(pkg: str) -> str:
    """ODNI package name -> cargo crate name. e.g. IC-Docbook -> ism-ic-docbook."""
    return "ism-" + pkg.lower()


def crate_dir(pkg: str) -> Path:
    return CRATES / crate_name(pkg)


def lib_ident(pkg: str) -> str:
    """crate name as a Rust identifier, e.g. ism-ic-docbook -> ism_ic_docbook."""
    return crate_name(pkg).replace("-", "_")


# --- parse legacy lib.rs ----------------------------------------------------

PACKAGES_RE = re.compile(
    r"pub const PACKAGES: &\[&str\] = &\[(.*?)\];", re.DOTALL
)
# Legacy 2-tuple form: (uri, "PKG/relpath")
NS_TABLE_2_RE = re.compile(
    r"const NAMESPACE_TO_PATH: &\[\(&str, &str\)\] = &\[(.*?)\];", re.DOTALL
)
NS_ENTRY_2_RE = re.compile(
    r'\(\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,?\s*\)', re.DOTALL
)
# New 3-tuple form: (uri, "PKG", "relpath_within_PKG")
NS_TABLE_3_RE = re.compile(
    r"const NAMESPACE_TO_PACKAGE: &\[\(&str, &str, &str\)\] = &\[(.*?)\];",
    re.DOTALL,
)
NS_ENTRY_3_RE = re.compile(
    r'\(\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,\s*"([^"]+)"\s*,?\s*\)', re.DOTALL
)


def parse_lib_rs(path: Path) -> tuple[list[str], list[tuple[str, str]]]:
    """Return (packages, [(uri, "PKG/relpath"), ...])."""
    src = path.read_text(encoding="utf-8")
    pkgs_match = PACKAGES_RE.search(src)
    if not pkgs_match:
        sys.exit(f"could not find PACKAGES const in {path}")
    pkgs = re.findall(r'"([^"]+)"', pkgs_match.group(1))

    # Try the 3-tuple (new meta-crate) form first, then 2-tuple (legacy).
    ns3 = NS_TABLE_3_RE.search(src)
    if ns3:
        triples = NS_ENTRY_3_RE.findall(ns3.group(1))
        return pkgs, [(uri, f"{pkg}/{rel}") for uri, pkg, rel in triples]

    ns2 = NS_TABLE_2_RE.search(src)
    if ns2:
        return pkgs, NS_ENTRY_2_RE.findall(ns2.group(1))

    sys.exit(
        f"could not find NAMESPACE_TO_PACKAGE or NAMESPACE_TO_PATH const in {path}"
    )


# --- hashing ----------------------------------------------------------------

def sha256_of_file(p: Path) -> str:
    h = hashlib.sha256()
    with open(p, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 17), b""):
            h.update(chunk)
    return h.hexdigest()


def sha256_of_bytes(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


# --- per-crate manifest -----------------------------------------------------

def build_manifest(data_dir: Path) -> tuple[str, str]:
    """Walk data_dir and produce (manifest_text, manifest_digest_hex).

    manifest_text format matches the original: '<sha>  <relpath>\\n'
    sorted lexicographically by relpath. Excludes _provenance/.
    """
    entries: list[tuple[str, str]] = []
    for dirpath, _, files in os.walk(data_dir):
        rel_dir = Path(dirpath).relative_to(data_dir).as_posix()
        if rel_dir == "_provenance" or rel_dir.startswith("_provenance/"):
            continue
        for name in files:
            full = Path(dirpath) / name
            rel = full.relative_to(data_dir).as_posix()
            entries.append((rel, sha256_of_file(full)))
    entries.sort()
    text = "".join(f"{sha}  {rel}\n" for rel, sha in entries)
    digest = sha256_of_bytes(text.encode("utf-8"))
    return text, digest


# --- generated source -------------------------------------------------------

CARGO_TEMPLATE = """\
# SPDX-License-Identifier: MIT-0 OR Unlicense

[package]
name = "{crate}"
version.workspace = true
edition.workspace = true
description = "ODNI {pkg} schema package, vendored. Designed as a build-dependency for codegen. SHA-256 verified at compile time."
license.workspace = true
repository.workspace = true{publish_block}
readme = "README.md"
keywords = ["odni", "ic", "ism", "xml", "schema"]
categories = ["data-structures", "parsing"]
build = "build.rs"

include = [
    "src/**/*",
    "data/**/*",
    "build.rs",
    "Cargo.toml",
    "README.md",
    "LICENSE*",
]

[lib]
path = "src/lib.rs"

[features]
default = ["verify-on-build"]
# Verify every file under data/ against the baked SHA-256 manifest at the
# *consumer's* compile time. Disable only if you understand what you're
# giving up — typically a CI environment that runs the same verification
# more thoroughly out of band.
verify-on-build = []

[dependencies]
sha2 = {{ workspace = true }}

[build-dependencies]
sha2 = {{ workspace = true }}
"""

BUILD_RS_TEMPLATE = '''\
// SPDX-License-Identifier: MIT-0 OR Unlicense

//! Build-time integrity check for the {pkg} package.
//!
//! Re-hashes every file under `data/` and compares against
//! `data/_provenance/manifest.txt`. If a single file differs, this crate
//! refuses to compile — meaning any consumer that uses
//! `[build-dependencies] {crate} = ...` cannot build with tampered
//! schemas.
//!
//! The check is opt-out via `--no-default-features` (the `verify-on-build`
//! feature is enabled by default).

use std::env;
use std::fs::File;
use std::io::{{BufRead, BufReader, Read}};
use std::path::{{Path, PathBuf}};

use sha2::{{Digest, Sha256}};

fn main() {{
    if env::var_os("CARGO_FEATURE_VERIFY_ON_BUILD").is_none() {{
        return;
    }}

    let manifest_dir =
        PathBuf::from(env::var_os("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR"));
    let data_dir = manifest_dir.join("data");
    let manifest_path = data_dir.join("_provenance/manifest.txt");
    let digest_path = data_dir.join("_provenance/manifest.sha256");

    println!("cargo:rerun-if-changed={{}}", manifest_path.display());
    println!("cargo:rerun-if-changed={{}}", digest_path.display());
    println!("cargo:rerun-if-env-changed=ISM_DATA_SKIP_VERIFY");

    if env::var_os("ISM_DATA_SKIP_VERIFY").is_some() {{
        println!(
            "cargo:warning={crate}: integrity check SKIPPED (ISM_DATA_SKIP_VERIFY set)"
        );
        return;
    }}

    let manifest_bytes = std::fs::read(&manifest_path).unwrap_or_else(|e| {{
        panic!(
            "{crate}: cannot read manifest.txt at {{}}: {{}}",
            manifest_path.display(),
            e
        )
    }});
    let manifest_digest_actual = hex_digest(&manifest_bytes);
    let manifest_digest_expected = std::fs::read_to_string(&digest_path)
        .unwrap_or_else(|e| {{
            panic!(
                "{crate}: cannot read manifest.sha256 at {{}}: {{}}",
                digest_path.display(),
                e
            )
        }})
        .trim()
        .to_owned();
    if manifest_digest_actual != manifest_digest_expected {{
        panic!(
            "{crate}: manifest.sha256 does not match SHA-256 of manifest.txt.\\n\\
             expected: {{}}\\n\\
             actual:   {{}}\\n\\
             Refusing to build — manifest itself appears tampered.",
            manifest_digest_expected, manifest_digest_actual,
        );
    }}

    let reader = BufReader::new(std::io::Cursor::new(manifest_bytes));
    let mut checked: usize = 0;
    let mut errors: Vec<String> = Vec::new();
    for line in reader.lines() {{
        let line = line.expect("read manifest line");
        if line.is_empty() {{
            continue;
        }}
        let (expected_sha, rel) = match line.split_once("  ") {{
            Some(parts) => parts,
            None => {{
                errors.push(format!("malformed manifest line: {{:?}}", line));
                continue;
            }}
        }};
        let path = data_dir.join(rel);
        match hash_file(&path) {{
            Ok(actual_sha) => {{
                if actual_sha != expected_sha {{
                    errors.push(format!(
                        "{{}}\\n    expected: {{}}\\n    actual:   {{}}",
                        rel, expected_sha, actual_sha
                    ));
                }}
            }}
            Err(e) => {{
                errors.push(format!("{{}}: {{}}", rel, e));
            }}
        }}
        checked += 1;
    }}

    if !errors.is_empty() {{
        let head: Vec<&String> = errors.iter().take(10).collect();
        let extra = if errors.len() > 10 {{
            format!("\\n  ...and {{}} more failure(s)", errors.len() - 10)
        }} else {{
            String::new()
        }};
        panic!(
            "{crate}: integrity check failed for {{}} of {{}} files.\\n\\
             First few:\\n  {{}}{{}}\\n\\
             Refusing to build — data/ has been tampered with or is corrupted.",
            errors.len(),
            checked,
            head.iter()
                .map(|s| s.as_str())
                .collect::<Vec<_>>()
                .join("\\n  "),
            extra,
        );
    }}

    println!(
        "cargo:warning={crate}: verified {{}} files against manifest (digest {{}})",
        checked,
        &manifest_digest_actual[..16]
    );
}}

fn hash_file(path: &Path) -> std::io::Result<String> {{
    let mut file = File::open(path)?;
    let mut hasher = Sha256::new();
    let mut buf = vec![0u8; 1 << 17];
    loop {{
        let n = file.read(&mut buf)?;
        if n == 0 {{
            break;
        }}
        hasher.update(&buf[..n]);
    }}
    Ok(hex_digest_finalized(hasher))
}}

fn hex_digest(bytes: &[u8]) -> String {{
    let mut h = Sha256::new();
    h.update(bytes);
    hex_digest_finalized(h)
}}

fn hex_digest_finalized(hasher: Sha256) -> String {{
    let bytes = hasher.finalize();
    let mut s = String::with_capacity(bytes.len() * 2);
    for b in bytes {{
        s.push_str(HEX[((b >> 4) & 0xf) as usize]);
        s.push_str(HEX[(b & 0xf) as usize]);
    }}
    s
}}

const HEX: [&str; 16] = [
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f",
];
'''

LIB_RS_TEMPLATE = '''\
// SPDX-License-Identifier: MIT-0 OR Unlicense

#![doc = include_str!("../README.md")]

use std::fs::File;
use std::io::{{self, BufRead, BufReader, Read}};
use std::path::{{Path, PathBuf}};

use sha2::{{Digest, Sha256}};

/// Original ODNI package name (preserves upstream casing).
pub const PACKAGE_NAME: &str = "{pkg}";

/// SHA-256 of `data/_provenance/manifest.txt`, baked at vendor time.
pub const MANIFEST_DIGEST: &str = "{manifest_digest}";

/// Number of files under `data/` covered by the manifest.
pub const FILE_COUNT: usize = {file_count};

/// Path to the materialized data tree shipped with this crate.
///
/// Resolves at the *consumer's* compile time to the location where
/// cargo placed this crate's source.
pub fn data_root() -> PathBuf {{
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("data")
}}

/// Path to the package's data directory: `data/{pkg}`.
pub fn package_root() -> PathBuf {{
    data_root().join(PACKAGE_NAME)
}}

/// Resolve an XML namespace URI to the canonical XSD that defines it,
/// scoped to this package only.
///
/// Returns `None` if the namespace is not declared by this package.
pub fn resolve_namespace(uri: &str) -> Option<PathBuf> {{
    NAMESPACES
        .binary_search_by_key(&uri, |&(ns, _)| ns)
        .ok()
        .map(|i| data_root().join(NAMESPACES[i].1))
}}

/// Iterate over every (namespace, relative path under `data/`) declared
/// by this package.
pub fn known_namespaces() -> impl Iterator<Item = (&'static str, &'static str)> {{
    NAMESPACES.iter().copied()
}}

// --- Integrity API ---

/// What can go wrong during integrity verification.
#[derive(Debug)]
pub enum VerifyError {{
    ManifestUnreadable(io::Error),
    ManifestTampered {{ expected: String, actual: String }},
    ManifestMalformed(String),
    FileUnreadable {{ rel: String, source: io::Error }},
    HashMismatch {{
        rel: String,
        expected: String,
        actual: String,
    }},
    Multiple(Vec<VerifyError>),
}}

impl std::fmt::Display for VerifyError {{
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {{
        match self {{
            VerifyError::ManifestUnreadable(e) => write!(f, "manifest.txt unreadable: {{}}", e),
            VerifyError::ManifestTampered {{ expected, actual }} => write!(
                f,
                "manifest.sha256 ({{}}) does not match SHA-256 of manifest.txt ({{}})",
                expected, actual,
            ),
            VerifyError::ManifestMalformed(line) => {{
                write!(f, "malformed manifest line: {{:?}}", line)
            }}
            VerifyError::FileUnreadable {{ rel, source }} => {{
                write!(f, "{{}}: {{}}", rel, source)
            }}
            VerifyError::HashMismatch {{
                rel,
                expected,
                actual,
            }} => write!(
                f,
                "hash mismatch for {{}}: expected {{}}, got {{}}",
                rel, expected, actual,
            ),
            VerifyError::Multiple(errs) => {{
                writeln!(f, "{{}} verification errors:", errs.len())?;
                for (i, e) in errs.iter().take(10).enumerate() {{
                    writeln!(f, "  [{{}}] {{}}", i + 1, e)?;
                }}
                if errs.len() > 10 {{
                    writeln!(f, "  ...and {{}} more", errs.len() - 10)?;
                }}
                Ok(())
            }}
        }}
    }}
}}

impl std::error::Error for VerifyError {{
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {{
        match self {{
            VerifyError::ManifestUnreadable(e) => Some(e),
            VerifyError::FileUnreadable {{ source, .. }} => Some(source),
            _ => None,
        }}
    }}
}}

/// Verify every file under `data/` against the baked SHA-256 manifest.
pub fn verify_integrity() -> Result<usize, VerifyError> {{
    let data = data_root();
    let manifest_path = data.join("_provenance/manifest.txt");
    let manifest = std::fs::read(&manifest_path).map_err(VerifyError::ManifestUnreadable)?;

    let actual_digest = hex_digest(&manifest);
    if actual_digest != MANIFEST_DIGEST {{
        return Err(VerifyError::ManifestTampered {{
            expected: MANIFEST_DIGEST.to_string(),
            actual: actual_digest,
        }});
    }}

    let reader = BufReader::new(std::io::Cursor::new(manifest));
    let mut errors: Vec<VerifyError> = Vec::new();
    let mut count: usize = 0;
    for line in reader.lines() {{
        let line = line.map_err(VerifyError::ManifestUnreadable)?;
        if line.is_empty() {{
            continue;
        }}
        let (expected, rel) = match line.split_once("  ") {{
            Some(parts) => parts,
            None => {{
                errors.push(VerifyError::ManifestMalformed(line.clone()));
                continue;
            }}
        }};
        match hash_file(&data.join(rel)) {{
            Ok(actual) if actual == expected => count += 1,
            Ok(actual) => errors.push(VerifyError::HashMismatch {{
                rel: rel.to_string(),
                expected: expected.to_string(),
                actual,
            }}),
            Err(e) => errors.push(VerifyError::FileUnreadable {{
                rel: rel.to_string(),
                source: e,
            }}),
        }}
    }}
    if errors.is_empty() {{
        Ok(count)
    }} else {{
        Err(VerifyError::Multiple(errors))
    }}
}}

/// Verify a single file under `data/` against the manifest.
pub fn verify_file(rel: &str) -> Result<(), VerifyError> {{
    let data = data_root();
    let manifest_path = data.join("_provenance/manifest.txt");
    let f = File::open(&manifest_path).map_err(VerifyError::ManifestUnreadable)?;
    let needle = format!("  {{}}", rel);
    for line in BufReader::new(f).lines() {{
        let line = line.map_err(VerifyError::ManifestUnreadable)?;
        if line.ends_with(&needle) {{
            let expected = &line[..64];
            let actual = hash_file(&data.join(rel)).map_err(|e| VerifyError::FileUnreadable {{
                rel: rel.to_string(),
                source: e,
            }})?;
            return if actual == expected {{
                Ok(())
            }} else {{
                Err(VerifyError::HashMismatch {{
                    rel: rel.to_string(),
                    expected: expected.to_string(),
                    actual,
                }})
            }};
        }}
    }}
    Err(VerifyError::ManifestMalformed(format!(
        "{{}} not in manifest",
        rel
    )))
}}

// --- internals ---

fn hash_file(path: &Path) -> io::Result<String> {{
    let mut file = File::open(path)?;
    let mut hasher = Sha256::new();
    let mut buf = vec![0u8; 1 << 17];
    loop {{
        let n = file.read(&mut buf)?;
        if n == 0 {{
            break;
        }}
        hasher.update(&buf[..n]);
    }}
    Ok(hex_finalize(hasher))
}}

fn hex_digest(bytes: &[u8]) -> String {{
    let mut h = Sha256::new();
    h.update(bytes);
    hex_finalize(h)
}}

fn hex_finalize(hasher: Sha256) -> String {{
    let bytes = hasher.finalize();
    let mut s = String::with_capacity(64);
    for b in bytes {{
        s.push(HEX[((b >> 4) & 0xf) as usize]);
        s.push(HEX[(b & 0xf) as usize]);
    }}
    s
}}

const HEX: [char; 16] = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f',
];

// --- generated namespace table ---

/// Namespaces declared by this package: `(uri, relpath under data/)`.
{namespaces_const}

// --- tests ---

#[cfg(test)]
mod tests {{
    use super::*;

    #[test]
    fn data_root_exists() {{
        assert!(data_root().is_dir());
    }}

    #[test]
    fn package_root_exists() {{
        assert!(package_root().is_dir());
    }}

    #[test]
    fn namespace_table_is_sorted() {{
        for w in NAMESPACES.windows(2) {{
            assert!(w[0].0 < w[1].0, "namespace table not sorted: {{}} >= {{}}", w[0].0, w[1].0);
        }}
    }}

    #[test]
    fn manifest_digest_const_is_64_hex_chars() {{
        assert_eq!(MANIFEST_DIGEST.len(), 64);
        assert!(MANIFEST_DIGEST.chars().all(|c| c.is_ascii_hexdigit()));
    }}

    // Full-tree verification is gated behind --ignored to keep cargo test fast.
    #[test]
    #[ignore]
    fn verify_full_tree() {{
        match verify_integrity() {{
            Ok(n) => assert_eq!(n, FILE_COUNT),
            Err(e) => panic!("{{}}", e),
        }}
    }}
}}
'''

README_TEMPLATE = """\
<!--
SPDX-License-Identifier: MIT-0 OR Unlicense
-->

# {crate}

Vendored ODNI **{pkg}** schema package, with SHA-256 integrity verification
at compile time.

Part of the [`ism-data`](https://github.com/marquetools/ism-data) workspace.

## Use

```toml
# Cargo.toml
[build-dependencies]
{crate} = {{ git = "https://github.com/marquetools/ism-data", tag = "v..." }}
```

```rust,ignore
// build.rs
let xsd = {ident}::package_root().join("Schema/{pkg}/{pkg}.xsd");
println!("cargo:rerun-if-changed={{}}", xsd.display());
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
"""

PROVENANCE_README = """\
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
"""


def render_namespace_const(entries: list[tuple[str, str]]) -> str:
    if not entries:
        return "const NAMESPACES: &[(&str, &str)] = &[];"
    lines = ["const NAMESPACES: &[(&str, &str)] = &["]
    for uri, rel in entries:
        lines.append(f'    ("{uri}", "{rel}"),')
    lines.append("];")
    return "\n".join(lines)


# --- main scaffolding -------------------------------------------------------

def write_if_changed(path: Path, content: str | bytes) -> bool:
    """Write content if file doesn't exist or differs. Returns True if changed."""
    path.parent.mkdir(parents=True, exist_ok=True)
    is_bytes = isinstance(content, bytes)
    if path.exists():
        existing = path.read_bytes() if is_bytes else path.read_text(encoding="utf-8")
        if existing == content:
            return False
    if is_bytes:
        path.write_bytes(content)
    else:
        path.write_text(content, encoding="utf-8")
    return True


def scaffold_crate(
    pkg: str,
    ns_entries: list[tuple[str, str]],
    move_data: bool,
    published: bool,
) -> dict:
    """Scaffold a single per-package crate. Returns summary info."""
    cdir = crate_dir(pkg)
    cname = crate_name(pkg)
    ident = lib_ident(pkg)

    cdata = cdir / "data"

    # 1. Move data (if not already moved)
    src_pkg_dir = DATA / pkg
    dst_pkg_dir = cdata / pkg
    if move_data and src_pkg_dir.exists():
        dst_pkg_dir.parent.mkdir(parents=True, exist_ok=True)
        if dst_pkg_dir.exists():
            print(
                f"  warn: {dst_pkg_dir} exists; removing source {src_pkg_dir}",
                file=sys.stderr,
            )
            shutil.rmtree(src_pkg_dir)
        else:
            shutil.move(str(src_pkg_dir), str(dst_pkg_dir))
    if not dst_pkg_dir.exists():
        sys.exit(f"missing data dir for {pkg}: {dst_pkg_dir}")

    # 2. Slice namespaces (entries whose path starts with "PKG/")
    pkg_prefix = f"{pkg}/"
    pkg_ns = [(u, r) for (u, r) in ns_entries if r.startswith(pkg_prefix)]
    pkg_ns.sort(key=lambda x: x[0])

    # 3. Build manifest
    manifest_text, manifest_digest = build_manifest(cdata)
    file_count = manifest_text.count("\n")

    # 4. Write provenance
    write_if_changed(cdata / "_provenance" / "manifest.txt", manifest_text)
    write_if_changed(cdata / "_provenance" / "manifest.sha256", manifest_digest + "\n")
    write_if_changed(cdata / "_provenance" / "README.md", PROVENANCE_README)

    # 5. Write Cargo.toml. If the package is on the crates.io allowlist
    #    (tools/published.toml), override the workspace `publish = false`
    #    default with `publish = true`.
    publish_block = (
        "\n# Override workspace default — listed in tools/published.toml.\npublish = true"
        if published
        else ""
    )
    write_if_changed(
        cdir / "Cargo.toml",
        CARGO_TEMPLATE.format(crate=cname, pkg=pkg, publish_block=publish_block),
    )

    # 6. Write build.rs
    write_if_changed(
        cdir / "build.rs",
        BUILD_RS_TEMPLATE.format(crate=cname, pkg=pkg),
    )

    # 7. Write src/lib.rs
    write_if_changed(
        cdir / "src" / "lib.rs",
        LIB_RS_TEMPLATE.format(
            pkg=pkg,
            manifest_digest=manifest_digest,
            file_count=file_count,
            namespaces_const=render_namespace_const(pkg_ns),
        ),
    )

    # 8. Write README
    write_if_changed(
        cdir / "README.md",
        README_TEMPLATE.format(crate=cname, pkg=pkg, ident=ident),
    )

    return {
        "package": pkg,
        "crate": cname,
        "manifest_digest": manifest_digest,
        "file_count": file_count,
        "namespace_count": len(pkg_ns),
    }


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--regen",
        action="store_true",
        help="don't move data; regenerate manifests + generated files in place",
    )
    ap.add_argument(
        "--source-lib",
        default=None,
        help="path to the source lib.rs for parsing PACKAGES + NAMESPACE_TO_PATH",
    )
    args = ap.parse_args()

    # Find source of truth for PACKAGES + NAMESPACE_TO_PATH.
    candidates = [
        Path(args.source_lib) if args.source_lib else None,
        ROOT / "src" / "lib.rs",
        CRATES / "ism-data" / "src" / "lib.rs",
    ]
    source = next((p for p in candidates if p and p.exists()), None)
    if not source:
        sys.exit("could not find source lib.rs to parse")

    print(f"parsing source: {source}", file=sys.stderr)
    packages, ns_entries = parse_lib_rs(source)
    print(
        f"  found {len(packages)} packages, {len(ns_entries)} namespace entries",
        file=sys.stderr,
    )

    published_set = load_published_packages()
    if published_set:
        print(
            f"  {len(published_set)} package(s) allowlisted for crates.io: "
            f"{', '.join(sorted(published_set))}",
            file=sys.stderr,
        )
    else:
        print(
            "  no per-package crates allowlisted for crates.io "
            "(tools/published.toml [packages] is empty)",
            file=sys.stderr,
        )

    CRATES.mkdir(exist_ok=True)
    summaries = []
    for pkg in packages:
        print(f"scaffolding {pkg} -> {crate_name(pkg)}", file=sys.stderr)
        summaries.append(
            scaffold_crate(
                pkg,
                ns_entries,
                move_data=not args.regen,
                published=pkg in published_set,
            )
        )

    # Print summary as JSON-ish for downstream tooling.
    total_files = sum(s["file_count"] for s in summaries)
    total_ns = sum(s["namespace_count"] for s in summaries)
    print(
        f"\nDone: {len(summaries)} crates, {total_files} files, "
        f"{total_ns} namespaces total",
        file=sys.stderr,
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
