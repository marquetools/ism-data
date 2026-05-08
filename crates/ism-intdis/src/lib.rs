// SPDX-License-Identifier: MIT-0 OR Unlicense

#![doc = include_str!("../README.md")]

use std::fs::File;
use std::io::{self, BufRead, BufReader, Read};
use std::path::{Path, PathBuf};

use sha2::{Digest, Sha256};

/// Original ODNI package name (preserves upstream casing).
pub const PACKAGE_NAME: &str = "INTDIS";

/// SHA-256 of `data/_provenance/manifest.txt`, baked at vendor time.
pub const MANIFEST_DIGEST: &str = "c64857707f6ae974d3be5c3e6d2c929318d0cb0b274f50185e47d5923939becb";

/// Number of files under `data/` covered by the manifest.
pub const FILE_COUNT: usize = 131;

/// Path to the materialized data tree shipped with this crate.
///
/// Resolves at the *consumer's* compile time to the location where
/// cargo placed this crate's source.
pub fn data_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("data")
}

/// Path to the package's data directory: `data/INTDIS`.
pub fn package_root() -> PathBuf {
    data_root().join(PACKAGE_NAME)
}

/// Resolve an XML namespace URI to the canonical XSD that defines it,
/// scoped to this package only.
///
/// Returns `None` if the namespace is not declared by this package.
pub fn resolve_namespace(uri: &str) -> Option<PathBuf> {
    NAMESPACES
        .binary_search_by_key(&uri, |&(ns, _)| ns)
        .ok()
        .map(|i| data_root().join(NAMESPACES[i].1))
}

/// Iterate over every (namespace, relative path under `data/`) declared
/// by this package.
pub fn known_namespaces() -> impl Iterator<Item = (&'static str, &'static str)> {
    NAMESPACES.iter().copied()
}

// --- Integrity API ---

/// What can go wrong during integrity verification.
#[derive(Debug)]
pub enum VerifyError {
    ManifestUnreadable(io::Error),
    ManifestTampered { expected: String, actual: String },
    ManifestMalformed(String),
    FileUnreadable { rel: String, source: io::Error },
    HashMismatch {
        rel: String,
        expected: String,
        actual: String,
    },
    Multiple(Vec<VerifyError>),
}

impl std::fmt::Display for VerifyError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            VerifyError::ManifestUnreadable(e) => write!(f, "manifest.txt unreadable: {}", e),
            VerifyError::ManifestTampered { expected, actual } => write!(
                f,
                "manifest.sha256 ({}) does not match SHA-256 of manifest.txt ({})",
                expected, actual,
            ),
            VerifyError::ManifestMalformed(line) => {
                write!(f, "malformed manifest line: {:?}", line)
            }
            VerifyError::FileUnreadable { rel, source } => {
                write!(f, "{}: {}", rel, source)
            }
            VerifyError::HashMismatch {
                rel,
                expected,
                actual,
            } => write!(
                f,
                "hash mismatch for {}: expected {}, got {}",
                rel, expected, actual,
            ),
            VerifyError::Multiple(errs) => {
                writeln!(f, "{} verification errors:", errs.len())?;
                for (i, e) in errs.iter().take(10).enumerate() {
                    writeln!(f, "  [{}] {}", i + 1, e)?;
                }
                if errs.len() > 10 {
                    writeln!(f, "  ...and {} more", errs.len() - 10)?;
                }
                Ok(())
            }
        }
    }
}

impl std::error::Error for VerifyError {
    fn source(&self) -> Option<&(dyn std::error::Error + 'static)> {
        match self {
            VerifyError::ManifestUnreadable(e) => Some(e),
            VerifyError::FileUnreadable { source, .. } => Some(source),
            _ => None,
        }
    }
}

/// Verify every file under `data/` against the baked SHA-256 manifest.
pub fn verify_integrity() -> Result<usize, VerifyError> {
    let data = data_root();
    let manifest_path = data.join("_provenance/manifest.txt");
    let manifest = std::fs::read(&manifest_path).map_err(VerifyError::ManifestUnreadable)?;

    let actual_digest = hex_digest(&manifest);
    if actual_digest != MANIFEST_DIGEST {
        return Err(VerifyError::ManifestTampered {
            expected: MANIFEST_DIGEST.to_string(),
            actual: actual_digest,
        });
    }

    let reader = BufReader::new(std::io::Cursor::new(manifest));
    let mut errors: Vec<VerifyError> = Vec::new();
    let mut count: usize = 0;
    for line in reader.lines() {
        let line = line.map_err(VerifyError::ManifestUnreadable)?;
        if line.is_empty() {
            continue;
        }
        let (expected, rel) = match line.split_once("  ") {
            Some(parts) => parts,
            None => {
                errors.push(VerifyError::ManifestMalformed(line.clone()));
                continue;
            }
        };
        match hash_file(&data.join(rel)) {
            Ok(actual) if actual == expected => count += 1,
            Ok(actual) => errors.push(VerifyError::HashMismatch {
                rel: rel.to_string(),
                expected: expected.to_string(),
                actual,
            }),
            Err(e) => errors.push(VerifyError::FileUnreadable {
                rel: rel.to_string(),
                source: e,
            }),
        }
    }
    if errors.is_empty() {
        Ok(count)
    } else {
        Err(VerifyError::Multiple(errors))
    }
}

/// Verify a single file under `data/` against the manifest.
pub fn verify_file(rel: &str) -> Result<(), VerifyError> {
    let data = data_root();
    let manifest_path = data.join("_provenance/manifest.txt");
    let f = File::open(&manifest_path).map_err(VerifyError::ManifestUnreadable)?;
    let needle = format!("  {}", rel);
    for line in BufReader::new(f).lines() {
        let line = line.map_err(VerifyError::ManifestUnreadable)?;
        if line.ends_with(&needle) {
            let expected = &line[..64];
            let actual = hash_file(&data.join(rel)).map_err(|e| VerifyError::FileUnreadable {
                rel: rel.to_string(),
                source: e,
            })?;
            return if actual == expected {
                Ok(())
            } else {
                Err(VerifyError::HashMismatch {
                    rel: rel.to_string(),
                    expected: expected.to_string(),
                    actual,
                })
            };
        }
    }
    Err(VerifyError::ManifestMalformed(format!(
        "{} not in manifest",
        rel
    )))
}

// --- internals ---

fn hash_file(path: &Path) -> io::Result<String> {
    let mut file = File::open(path)?;
    let mut hasher = Sha256::new();
    let mut buf = vec![0u8; 1 << 17];
    loop {
        let n = file.read(&mut buf)?;
        if n == 0 {
            break;
        }
        hasher.update(&buf[..n]);
    }
    Ok(hex_finalize(hasher))
}

fn hex_digest(bytes: &[u8]) -> String {
    let mut h = Sha256::new();
    h.update(bytes);
    hex_finalize(h)
}

fn hex_finalize(hasher: Sha256) -> String {
    let bytes = hasher.finalize();
    let mut s = String::with_capacity(64);
    for b in bytes {
        s.push(HEX[((b >> 4) & 0xf) as usize]);
        s.push(HEX[(b & 0xf) as usize]);
    }
    s
}

const HEX: [char; 16] = [
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f',
];

// --- generated namespace table ---

/// Namespaces declared by this package: `(uri, relpath under data/)`.
const NAMESPACES: &[(&str, &str)] = &[
    ("urn:us:gov:ic:cvenum:intdis:inteldiscipline", "INTDIS/Schema/INTDIS/CVEGenerated/CVEnumIntelDiscipline.xsd"),
    ("urn:us:gov:ic:cvenum:intdis:inteldiscipline:component", "INTDIS/Schema/INTDIS/CVEGenerated/CVEnumIntelDisciplineComponent.xsd"),
    ("urn:us:gov:ic:cvenum:intdis:inteldiscipline:component:technique", "INTDIS/Schema/INTDIS/CVEGenerated/CVEnumIntelDisciplineComponentTechnique.xsd"),
    ("urn:us:gov:ic:intdis", "INTDIS/Schema/INTDIS/IntelDiscipline.xsd"),
];

// --- tests ---

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn data_root_exists() {
        assert!(data_root().is_dir());
    }

    #[test]
    fn package_root_exists() {
        assert!(package_root().is_dir());
    }

    #[test]
    fn namespace_table_is_sorted() {
        for w in NAMESPACES.windows(2) {
            assert!(w[0].0 < w[1].0, "namespace table not sorted: {} >= {}", w[0].0, w[1].0);
        }
    }

    #[test]
    fn manifest_digest_const_is_64_hex_chars() {
        assert_eq!(MANIFEST_DIGEST.len(), 64);
        assert!(MANIFEST_DIGEST.chars().all(|c| c.is_ascii_hexdigit()));
    }

    // Full-tree verification is gated behind --ignored to keep cargo test fast.
    #[test]
    #[ignore]
    fn verify_full_tree() {
        match verify_integrity() {
            Ok(n) => assert_eq!(n, FILE_COUNT),
            Err(e) => panic!("{}", e),
        }
    }
}
