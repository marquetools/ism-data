// SPDX-License-Identifier: MIT-0 OR Unlicense

#![doc = include_str!("../README.md")]

use std::fs::File;
use std::io::{self, BufRead, BufReader, Read};
use std::path::{Path, PathBuf};

use sha2::{Digest, Sha256};

/// Original ODNI package name (preserves upstream casing).
pub const PACKAGE_NAME: &str = "DOMEX";

/// SHA-256 of `data/_provenance/manifest.txt`, baked at vendor time.
pub const MANIFEST_DIGEST: &str = "db40fd7558d437cd565041d9affe762e04edbaf55c5bdbcfd339a063a5b1f866";

/// Number of files under `data/` covered by the manifest.
pub const FILE_COUNT: usize = 1383;

/// Path to the materialized data tree shipped with this crate.
///
/// Resolves at the *consumer's* compile time to the location where
/// cargo placed this crate's source.
pub fn data_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("data")
}

/// Path to the package's data directory: `data/DOMEX`.
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
    ("urn:CellexReport", "DOMEX/Schema/DOMEX/CellexReport.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityCombatOperations", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityCombatOperations.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityCommunications", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityCommunications.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityCriminalActivities", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityCriminalActivities.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityFinance", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityFinance.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityHostageOperations", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityHostageOperations.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityIndividual", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityIndividual.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityPersonnelManagement", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityPersonnelManagement.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityPlanningGeneral", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityPlanningGeneral.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityPropagandaProductionandDistribution", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityPropagandaProductionandDistribution.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityRecruitmentOperations", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityRecruitmentOperations.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityReligious", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityReligious.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityWeaponsCyber", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityWeaponsCyber.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityWeaponsImprovised", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityWeaponsImprovised.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityWeaponsManufactured", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityWeaponsManufactured.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityWeaponsofMassDestruction", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityWeaponsofMassDestruction.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAffiliationTypeType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXAffiliationTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyCIA", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyCIA.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyDHS", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyDHS.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyDIA", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyDIA.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyDOD", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyDOD.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyDOJ", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyDOJ.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyFBI", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyFBI.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyNSA", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyNSA.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyOtherUSG", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyOtherUSG.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyUSA", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyUSA.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyUSAF", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyUSAF.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyUSMC", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyUSMC.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyUSN", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyUSN.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXCitizenshipStatusType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXCitizenshipStatusType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXCollectingUnitIDTypeType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXCollectingUnitIDTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXDispositionType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXDispositionType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXDocumentType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXDocumentType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXEducationDegreeType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXEducationDegreeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXEducationLevelType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXEducationLevelType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXEntityMethodOfExtractionType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXEntityMethodOfExtractionType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXEventTypeType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXEventTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXFileType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXFileType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXFinancialAccountTypeType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXFinancialAccountTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXFinancialTransactionTypeType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXFinancialTransactionTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXFisaType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXFisaType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXFlightTypeType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXFlightTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXHashDigestTypeType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXHashDigestTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXImageSizeTypeType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXImageSizeTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXLegalTitleType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXLegalTitleType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXLicenseTypeType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXLicenseTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXMediaType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXMediaType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXMembershipIdentificationTypeType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXMembershipIdentificationTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXMicroCollectionLocationDescriptorTypeType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXMicroCollectionLocationDescriptorTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXNumberOfFilesTypeType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXNumberOfFilesTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXOrganizationNameTypeType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXOrganizationNameTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXOrganizationTypeType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXOrganizationTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXPhysicalAttributeTypeType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXPhysicalAttributeTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXRelationshipNatureType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXRelationshipNatureType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXRelationshipTypeType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXRelationshipTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXTitleTypeType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXTitleTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXTranslationPriorityType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXTranslationPriorityType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXTranslationStatusType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXTranslationStatusType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXTranslationType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXTranslationType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXTravelTypeType", "DOMEX/Schema/DOMEX/CVEGenerated/CVEnumDOMEXTravelTypeType.xsd"),
    ("urn:us:mil:ces:metadata:domex", "DOMEX/Schema/DOMEX/DOMEX.xsd"),
    ("urn:us:mil:ces:metadata:domex_identity", "DOMEX/Schema/DOMEX/Identity.xsd"),
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
