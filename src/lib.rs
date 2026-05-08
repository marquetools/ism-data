// SPDX-License-Identifier: MIT-0 OR Unlicense

//! ODNI public XML schemas, deduplicated and consolidated.
//!
//! Intended to be consumed as a `[build-dependencies]` entry by Rust
//! projects that codegen Rust types from the ODNI XSDs.
//!
//! # Quick start (in your `build.rs`)
//!
//! ```no_run
//! let ismcat_root = odni_schemas::package("ISMCAT");
//! let ismcat_xsd = ismcat_root.join("Schema/ISMCAT/ISMCAT.xsd");
//! println!("cargo:rerun-if-changed={}", ismcat_xsd.display());
//! ```
//!
//! # Resolving by namespace
//!
//! ```no_run
//! let p = odni_schemas::resolve_namespace("urn:us:gov:ic:ismcat")
//!     .expect("ISMCAT namespace is part of the ODNI set");
//! ```
//!
//! # Integrity
//!
//! Every file under `data/` is hashed (SHA-256) at vendor time and the
//! hashes are baked into `data/_provenance/manifest.txt`. By default
//! the crate's `build.rs` re-verifies every file at the consumer's
//! compile time and refuses to compile on mismatch. See `SECURITY.md`
//! for the full threat model.
//!
//! For runtime spot-checks, use [`verify_integrity`] or [`verify_file`].

use std::fs::File;
use std::io::{self, BufRead, BufReader, Read};
use std::path::{Path, PathBuf};

use sha2::{Digest, Sha256};

// --- Path helpers ---

/// Path to the materialized data tree shipped with this crate.
///
/// Resolves at the *consumer's* compile time to the location where
/// cargo placed this crate's source (e.g. inside `~/.cargo/git/checkouts/`)
/// — exactly where the schema files live on disk.
pub fn data_root() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("data")
}

/// Path to a specific ODNI package directory, e.g. `package("ISMCAT")`.
pub fn package(name: &str) -> PathBuf {
    data_root().join(name)
}

/// Resolve an XML namespace URI to the canonical XSD that defines it.
///
/// Returns `None` if the namespace is not part of the ODNI schema set
/// (e.g. upstream W3C namespaces, or a typo).
pub fn resolve_namespace(uri: &str) -> Option<PathBuf> {
    NAMESPACE_TO_PATH
        .binary_search_by_key(&uri, |&(ns, _)| ns)
        .ok()
        .map(|i| data_root().join(NAMESPACE_TO_PATH[i].1))
}

/// Iterate over every (namespace, relative path under `data/`) the crate knows.
pub fn known_namespaces() -> impl Iterator<Item = (&'static str, &'static str)> {
    NAMESPACE_TO_PATH.iter().copied()
}

// --- Integrity API ---

/// SHA-256 of `data/_provenance/manifest.txt`, baked at vendor time.
///
/// Use this as a stable identifier for a particular vendor of the schemas
/// — pin it in release notes, signed tags, or external attestations to
/// detect manifest tampering from outside the crate.
pub const MANIFEST_DIGEST: &str = "e48332b249db1e9d0340bec6ddc913b5bbd95e68ab8033ff0ee80fe9a74daf61";

/// What can go wrong during integrity verification.
#[derive(Debug)]
pub enum VerifyError {
    /// The manifest file itself could not be read.
    ManifestUnreadable(io::Error),
    /// The manifest's recorded digest doesn't match the manifest's content.
    ManifestTampered { expected: String, actual: String },
    /// A line in the manifest is malformed.
    ManifestMalformed(String),
    /// A file referenced in the manifest could not be opened.
    FileUnreadable { rel: String, source: io::Error },
    /// A file's actual SHA-256 does not match the manifest.
    HashMismatch {
        rel: String,
        expected: String,
        actual: String,
    },
    /// One or more files failed verification (returned by `verify_integrity`).
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
            VerifyError::ManifestMalformed(line) => write!(f, "malformed manifest line: {:?}", line),
            VerifyError::FileUnreadable { rel, source } => {
                write!(f, "{}: {}", rel, source)
            }
            VerifyError::HashMismatch { rel, expected, actual } => write!(
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
///
/// Returns `Ok(n)` with the number of files verified, or
/// `Err(VerifyError::Multiple(...))` listing every mismatch.
///
/// This walks ~14k files and is intentionally not cheap — call it from
/// startup, a CI step, or a periodic integrity sweep, not from a hot path.
pub fn verify_integrity() -> Result<usize, VerifyError> {
    let data = data_root();
    let manifest_path = data.join("_provenance/manifest.txt");
    let manifest = std::fs::read(&manifest_path).map_err(VerifyError::ManifestUnreadable)?;

    // Top-level digest check first — cheap, catches manifest tampering.
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
///
/// `rel` is the path relative to `data_root()` — e.g.
/// `"ISMCAT/Schema/ISMCAT/ISMCAT.xsd"`.
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
        "{} not in manifest", rel
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

// --- generated tables ---

/// Names of the 58 ODNI packages shipped under `data/`.
pub const PACKAGES: &[&str] = &[
    "ADD-ERM",
    "ARH",
    "ATOM",
    "AUDIT",
    "AUTHCAT",
    "BASE-TDF",
    "BOE",
    "BRK-SRCH",
    "CDR-RA",
    "CDSM",
    "CDSM-TDF",
    "CEM",
    "CSR",
    "DED",
    "DELIVER",
    "DHZM",
    "DHZM-TDF",
    "DHZMC-TDF",
    "DOMEX",
    "ERM",
    "FAC",
    "FSD",
    "IC-Docbook",
    "IC-EDH",
    "IC-GENC",
    "IC-ID",
    "IC-SF",
    "ICO-ACES",
    "ICO-NTK",
    "INTDIS",
    "IRM",
    "ISM-ACES",
    "ISM-Rollup",
    "ISMCAT",
    "ITS-MS",
    "ITS-OM",
    "LIC",
    "MAC",
    "MANAGE",
    "MIME",
    "MN",
    "MNT",
    "NTK",
    "NTK-ACES",
    "OC-NTK-ACES",
    "PM",
    "PMA",
    "QM",
    "ROLE",
    "RR-ID",
    "RR-SM",
    "RevRecall",
    "UIAS",
    "UIAS-APCS",
    "USAgency",
    "VIRT",
    "WSS-HLG",
    "WSS-SIGENC",
    "Whitelist",
];

/// Sorted (namespace, relative path under `data/`) pairs. 235 entries.
const NAMESPACE_TO_PATH: &[(&str, &str)] = &[
    ("http://docbook.org/ns/docbook", "IC-Docbook/XSL/IC-Docbook/docbook-xsl-1.79.2/slides/schema/xsd/docbook.xsd"),
    ("http://docbook.org/ns/docbook-slides", "IC-Docbook/XSL/IC-Docbook/docbook-xsl-1.79.2/slides/schema/xsd/slides.xsd"),
    ("http://metadata.dod.mil/mdr/ns/DDMS/3.0/", "AUDIT/CVE/Schema/DDMS/DDMS-GeospatialCoverage.xsd"),
    ("http://www.opengis.net/gml/3.2", "AUDIT/CVE/Schema/DDMS/DDMS-GML-Profile.xsd"),
    ("http://www.w3.org/1999/xlink", "AUDIT/Schema/XLINK/XLink.xsd"),
    ("http://www.w3.org/2001/SMIL20/", "RR-SM/Schema/w3/2001/SMIL20/smil20-4gml.xsd"),
    ("http://www.w3.org/2001/SMIL20/Language", "RR-SM/Schema/w3/2001/SMIL20/smil20-language-4gml.xsd"),
    ("http://www.w3.org/XML/1998/namespace", "AUDIT/Schema/W3C-XML/W3C-XML-Namespace.xsd"),
    ("urn:CellexReport", "DOMEX/Schema/DOMEX/CellexReport.xsd"),
    ("urn:schema:guide:schema:cdsmanifest", "CDSM/Schema/CDSM/SchemaGuideSchema.xsd"),
    ("urn:schema:guide:schema:digitalhazmat", "DHZM/Schema/DHZM/SchemaGuideSchema.xsd"),
    ("urn:schema:guide:schema:irm", "IRM/Schema/IRM/SchemaGuideSchema.xsd"),
    ("urn:schema:guide:schema:ismcat", "ISMCAT/Schema/ISMCAT/SchemaGuideSchema.xsd"),
    ("urn:schema:guide:schema:its", "ITS-MS/Schema/ITS-MS/SchemaGuideSchema.xsd"),
    ("urn:schema:guide:schema:mac", "MAC/Schema/MAC/SchemaGuideSchema.xsd"),
    ("urn:schema:guide:schema:pma", "PMA/Schema/PMA/SchemaGuideSchema.xsd"),
    ("urn:schema:guide:schema:pubs", "MNT/Schema/MNT/SchemaGuideSchema.xsd"),
    ("urn:schema:guide:schema:rr", "RevRecall/Schema/RevRecall/SchemaGuideSchema.xsd"),
    ("urn:us:gov:ic:arh", "ARH/Schema/ARH/IC-ARH.xsd"),
    ("urn:us:gov:ic:audit", "AUDIT/Schema/AUDIT/IC-AUDIT.xsd"),
    ("urn:us:gov:ic:audit-cvenum", "AUDIT/Schema/AUDIT/CVEGeneratedTypes.xsd"),
    ("urn:us:gov:ic:authcat", "AUTHCAT/Schema/AUTHCAT/AuthorityCategory.xsd"),
    ("urn:us:gov:ic:boe", "BOE/Schema/BOE/BOE.xsd"),
    ("urn:us:gov:ic:cdsmanifest", "CDSM/Schema/CDSM/CDSM-guard.xsd"),
    ("urn:us:gov:ic:cem", "CEM/Schema/CEM/CEM-XML.xsd"),
    ("urn:us:gov:ic:common", "AUDIT/Schema/IC-COMMON/IC-Common.xsd"),
    ("urn:us:gov:ic:cve", "AUTHCAT/CVE/CveSchema/CVEXml.xsd"),
    ("urn:us:gov:ic:cve:v1", "AUDIT/CVE/Schema/CVEXml.xsd"),
    ("urn:us:gov:ic:cvenum:authcat:authcattype", "AUTHCAT/Schema/AUTHCAT/CVEGenerated/CVEnumAuthCatType.xsd"),
    ("urn:us:gov:ic:cvenum:boe:CVEnumBOEAuthorizationType", "BOE/Schema/BOE/CVEGenerated/CVEnumBOEAuthorizationType.xsd"),
    ("urn:us:gov:ic:cvenum:boe:CVEnumBOEInformationTechnologyType", "BOE/Schema/BOE/CVEGenerated/CVEnumBOEInformationTechnologyType.xsd"),
    ("urn:us:gov:ic:cvenum:boe:CVEnumBOESoftwareCategory", "BOE/Schema/BOE/CVEGenerated/CVEnumBOESoftwareCategory.xsd"),
    ("urn:us:gov:ic:cvenum:boe:CVEnumBOESystemOwnershipType", "BOE/Schema/BOE/CVEGenerated/CVEnumBOESystemOwnershipType.xsd"),
    ("urn:us:gov:ic:cvenum:boe:CVEnumBOESystemUserCategory", "BOE/Schema/BOE/CVEGenerated/CVEnumBOESystemUserCategory.xsd"),
    ("urn:us:gov:ic:cvenum:cemxml:citycategory", "CEM/Schema/CEM/CVEGenerated/CVEnumCemCityCategory.xsd"),
    ("urn:us:gov:ic:cvenum:cemxml:commdatatype", "CEM/Schema/CEM/CVEGenerated/CVEnumCemCommDataType.xsd"),
    ("urn:us:gov:ic:cvenum:cemxml:identifiertype", "CEM/Schema/CEM/CVEGenerated/CVEnumCemIdentifierType.xsd"),
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
    ("urn:us:gov:ic:cvenum:erm:holdCategory", "ERM/Schema/ERM/CVEGenerated/CVEnumERMHoldCategory.xsd"),
    ("urn:us:gov:ic:cvenum:fac:fineaccesscontroltype", "FAC/Schema/FAC/CVEGenerated/CVEnumFineAccessControlType.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country", "IC-GENC/Schema/IC-GENC/CVEGenerated/CVEnumGENCCountryCode.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:33", "IC-GENC/Schema/IC-GENC/CVEGenerated/CVEnumGeGENC3ed3.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:331", "IC-GENC/Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-1.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:3310", "IC-GENC/Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-10.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:3311", "IC-GENC/Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-11.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:332", "IC-GENC/Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-2.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:333", "IC-GENC/Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-3.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:334", "IC-GENC/Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-4.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:335", "IC-GENC/Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-5.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:336", "IC-GENC/Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-6.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:337", "IC-GENC/Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-7.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:338", "IC-GENC/Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-8.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:339", "IC-GENC/Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-9.xsd"),
    ("urn:us:gov:ic:cvenum:genc:subdivision", "IC-GENC/Schema/IC-GENC/CVEGenerated/CVEnumGENCSubDivisionCode.xsd"),
    ("urn:us:gov:ic:cvenum:intdis:inteldiscipline", "INTDIS/Schema/INTDIS/CVEGenerated/CVEnumIntelDiscipline.xsd"),
    ("urn:us:gov:ic:cvenum:intdis:inteldiscipline:component", "INTDIS/Schema/INTDIS/CVEGenerated/CVEnumIntelDisciplineComponent.xsd"),
    ("urn:us:gov:ic:cvenum:intdis:inteldiscipline:component:technique", "INTDIS/Schema/INTDIS/CVEGenerated/CVEnumIntelDisciplineComponentTechnique.xsd"),
    ("urn:us:gov:ic:cvenum:irm:activity", "IRM/Schema/IRM/CVEGenerated/CVEnumIRMActivity.xsd"),
    ("urn:us:gov:ic:cvenum:irm:complies:usa", "IRM/Schema/IRM/CVEGenerated/CVEnumIRMCompliesWithUSA.xsd"),
    ("urn:us:gov:ic:cvenum:irm:coverage:iso3166:digraph", "IRM/Schema/IRM/CVEGenerated/CVEnumIRMCoverageISO3166Digraph.xsd"),
    ("urn:us:gov:ic:cvenum:irm:coverage:precedence", "IRM/Schema/IRM/CVEGenerated/CVEnumIRMCoveragePrecedence.xsd"),
    ("urn:us:gov:ic:cvenum:irm:executableindicator", "IRM/Schema/IRM/CVEGenerated/CVEnumIRMExecutableIndicator.xsd"),
    ("urn:us:gov:ic:cvenum:irm:iso639-2:trigraph", "IRM/Schema/IRM/CVEGenerated/CVEnumIRMISO639-2Trigraph.xsd"),
    ("urn:us:gov:ic:cvenum:irm:iso639-3:trigraph", "IRM/Schema/IRM/CVEGenerated/CVEnumIRMISO639-3Trigraph.xsd"),
    ("urn:us:gov:ic:cvenum:irm:iso639:digraph", "IRM/Schema/IRM/CVEGenerated/CVEnumIRMISO639Digraph.xsd"),
    ("urn:us:gov:ic:cvenum:irm:language:qualifier", "IRM/Schema/IRM/CVEGenerated/CVEnumIRMCompoundLanguageQualifierType.xsd"),
    ("urn:us:gov:ic:cvenum:irm:maliciouscodeindicator", "IRM/Schema/IRM/CVEGenerated/CVEnumIRMMaliciousCodeIndicator.xsd"),
    ("urn:us:gov:ic:cvenum:irm:positive:intel", "IRM/Schema/IRM/CVEGenerated/CVEnumIRMPositiveIntel.xsd"),
    ("urn:us:gov:ic:cvenum:irm:waterBody", "IRM/Schema/IRM/CVEGenerated/CVEnumIRMWaterBody.xsd"),
    ("urn:us:gov:ic:cvenum:ism:25x", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISM25X.xsd"),
    ("urn:us:gov:ic:cvenum:ism:HighWaterNATO", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMHighWaterNATO.xsd"),
    ("urn:us:gov:ic:cvenum:ism:atomicEnergyMarkings", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMAtomicEnergyMarkings.xsd"),
    ("urn:us:gov:ic:cvenum:ism:attributes", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMAttributes.xsd"),
    ("urn:us:gov:ic:cvenum:ism:classification:all", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMClassificationAll.xsd"),
    ("urn:us:gov:ic:cvenum:ism:classification:us", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMClassificationUS.xsd"),
    ("urn:us:gov:ic:cvenum:ism:complieswith", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMCompliesWith.xsd"),
    ("urn:us:gov:ic:cvenum:ism:cuibasic", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMCUIBasic.xsd"),
    ("urn:us:gov:ic:cvenum:ism:cuispecified", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMCUISpecified.xsd"),
    ("urn:us:gov:ic:cvenum:ism:dissem", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMDissem.xsd"),
    ("urn:us:gov:ic:cvenum:ism:dissem:commingled", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMDissemCommingled.xsd"),
    ("urn:us:gov:ic:cvenum:ism:dissem:cui", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMDissemCui.xsd"),
    ("urn:us:gov:ic:cvenum:ism:dissem:icrm", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMDissemIcrm.xsd"),
    ("urn:us:gov:ic:cvenum:ism:elements", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMElements.xsd"),
    ("urn:us:gov:ic:cvenum:ism:exemptfrom", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMExemptFrom.xsd"),
    ("urn:us:gov:ic:cvenum:ism:fgiopen", "RR-SM/Schema/ISM/CVEGenerated/CVEnumISMFGIOpen.xsd"),
    ("urn:us:gov:ic:cvenum:ism:fgiprotected", "RR-SM/Schema/ISM/CVEGenerated/CVEnumISMFGIProtected.xsd"),
    ("urn:us:gov:ic:cvenum:ism:nonic", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMNonIC.xsd"),
    ("urn:us:gov:ic:cvenum:ism:nonuscontrols", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMNonUSControls.xsd"),
    ("urn:us:gov:ic:cvenum:ism:notice", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMNotice.xsd"),
    ("urn:us:gov:ic:cvenum:ism:noticeprose", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMNoticeProse.xsd"),
    ("urn:us:gov:ic:cvenum:ism:ownerproducer", "RR-SM/Schema/ISM/CVEGenerated/CVEnumISMOwnerProducer.xsd"),
    ("urn:us:gov:ic:cvenum:ism:pocType", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMPocType.xsd"),
    ("urn:us:gov:ic:cvenum:ism:relto", "RR-SM/Schema/ISM/CVEGenerated/CVEnumISMRelTo.xsd"),
    ("urn:us:gov:ic:cvenum:ism:sar", "FAC/Schema/FAC/CVEGenerated/CVEnumFACSARAuthorities.xsd"),
    ("urn:us:gov:ic:cvenum:ism:scicontrols", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMSCIControls.xsd"),
    ("urn:us:gov:ic:cvenum:ism:secondbannerline", "AUTHCAT/CVE/CveSchema/ISM/CVEGenerated/CVEnumISMSecondBannerLine.xsd"),
    ("urn:us:gov:ic:cvenum:ismcat:fgiopen", "ISMCAT/Schema/ISMCAT/CVEGenerated/CVEnumISMCATFGIOpen.xsd"),
    ("urn:us:gov:ic:cvenum:ismcat:fgiprotected", "ISMCAT/Schema/ISMCAT/CVEGenerated/CVEnumISMCATFGIProtected.xsd"),
    ("urn:us:gov:ic:cvenum:ismcat:ownerproducer", "ISMCAT/Schema/ISMCAT/CVEGenerated/CVEnumISMCATOwnerProducer.xsd"),
    ("urn:us:gov:ic:cvenum:ismcat:relto", "ISMCAT/Schema/ISMCAT/CVEGenerated/CVEnumISMCATRelTo.xsd"),
    ("urn:us:gov:ic:cvenum:ismcat:responsibleentity", "ISMCAT/Schema/ISMCAT/CVEGenerated/CVEnumISMCATResponsibleEntity.xsd"),
    ("urn:us:gov:ic:cvenum:ismcat:tetragraph", "ISMCAT/Schema/ISMCAT/CVEGenerated/CVEnumISMCATTetragraph.xsd"),
    ("urn:us:gov:ic:cvenum:itsms:fabric", "ITS-MS/Schema/ITS-MS/CVEGenerated/CVEnumITSMSFabric.xsd"),
    ("urn:us:gov:ic:cvenum:lic:license", "LIC/Schema/LIC/CVEGenerated/CVEnumLicLicense.xsd"),
    ("urn:us:gov:ic:cvenum:mac:collectionType", "MAC/Schema/MAC/CVEGenerated/CVEnumMacCollectionType.xsd"),
    ("urn:us:gov:ic:cvenum:mime:type", "MIME/Schema/MIME/CVEGenerated/CVEnumMIMEIANAType.xsd"),
    ("urn:us:gov:ic:cvenum:mn:issue", "MN/Schema/MN/CVEGenerated/CVEnumMNIssue.xsd"),
    ("urn:us:gov:ic:cvenum:mn:region", "MN/Schema/MN/CVEGenerated/CVEnumMNRegion.xsd"),
    ("urn:us:gov:ic:cvenum:ntk:accesspolicy", "NTK/Schema/NTK/CVEGenerated/CVEnumNTKAccessPolicy.xsd"),
    ("urn:us:gov:ic:cvenum:ntk:profiledes", "NTK/Schema/NTK/CVEGenerated/CVEnumNTKProfileDes.xsd"),
    ("urn:us:gov:ic:cvenum:pm:actor", "PM/Schema/PM/CVEGenerated/CVEnumPMActor.xsd"),
    ("urn:us:gov:ic:cvenum:pm:location", "PM/Schema/PM/CVEGenerated/CVEnumPMLocation.xsd"),
    ("urn:us:gov:ic:cvenum:pm:nonstateactors", "PM/Schema/PM/CVEGenerated/CVEnumPMNonStateActors.xsd"),
    ("urn:us:gov:ic:cvenum:pm:subject", "PM/Schema/PM/CVEGenerated/CVEnumPMSubject.xsd"),
    ("urn:us:gov:ic:cvenum:revrecall:action", "RevRecall/Schema/RevRecall/CVEGenerated/CVEnumRevRecallAction.xsd"),
    ("urn:us:gov:ic:cvenum:revrecall:type", "RevRecall/Schema/RevRecall/CVEGenerated/CVEnumRevRecallType.xsd"),
    ("urn:us:gov:ic:cvenum:role:c2sfunction", "ROLE/Schema/ROLE/CVEGenerated/CVEnumROLEC2SFunction.xsd"),
    ("urn:us:gov:ic:cvenum:role:c2sscope", "ROLE/Schema/ROLE/CVEGenerated/CVEnumROLEC2SScope.xsd"),
    ("urn:us:gov:ic:cvenum:role:enterprise:role", "ROLE/Schema/ROLE/CVEGenerated/CVEnumROLEEnterpriseRole.xsd"),
    ("urn:us:gov:ic:cvenum:role:namespace", "ROLE/Schema/ROLE/CVEGenerated/CVEnumROLENamespace.xsd"),
    ("urn:us:gov:ic:cvenum:role:nebula:namedrole", "ROLE/Schema/ROLE/CVEGenerated/CVEnumROLENebulaNamedRole.xsd"),
    ("urn:us:gov:ic:cvenum:role:paasfunction", "ROLE/Schema/ROLE/CVEGenerated/CVEnumROLEPAASFunction.xsd"),
    ("urn:us:gov:ic:cvenum:role:paasscope", "ROLE/Schema/ROLE/CVEGenerated/CVEnumROLEPAASScope.xsd"),
    ("urn:us:gov:ic:cvenum:tdf:hashalgorithm", "BASE-TDF/Schema/BASE-TDF/CVEGenerated/CVEnumTDFHashAlgorithm.xsd"),
    ("urn:us:gov:ic:cvenum:tdf:signaturealgorithm", "BASE-TDF/Schema/BASE-TDF/CVEGenerated/CVEnumTDFSignatureAlgorithm.xsd"),
    ("urn:us:gov:ic:cvenum:tdf:state", "BASE-TDF/Schema/BASE-TDF/CVEGenerated/CVEnumTDFAppliesToState.xsd"),
    ("urn:us:gov:ic:cvenum:uias:attribute", "UIAS/Schema/UIAS/CVEGenerated/CVEnumUIASAttribute.xsd"),
    ("urn:us:gov:ic:cvenum:uias:certificateauthority", "UIAS/Schema/UIAS/CVEGenerated/CVEnumUIASCertificateAuthority.xsd"),
    ("urn:us:gov:ic:cvenum:uias:clearance", "UIAS/Schema/UIAS/CVEGenerated/CVEnumUIASClearance.xsd"),
    ("urn:us:gov:ic:cvenum:uias:entitytype", "UIAS/Schema/UIAS/CVEGenerated/CVEnumUIASEntityType.xsd"),
    ("urn:us:gov:ic:cvenum:uias:handlingControls", "UIAS/Schema/UIAS/CVEGenerated/CVEnumUIASHandlingControls.xsd"),
    ("urn:us:gov:ic:cvenum:uias:lifecyclestatus", "UIAS/Schema/UIAS/CVEGenerated/CVEnumUIASLifeCycleStatus.xsd"),
    ("urn:us:gov:ic:cvenum:uias:nonpersonentitytype", "UIAS/Schema/UIAS/CVEGenerated/CVEnumUIASNonPersonEntityType.xsd"),
    ("urn:us:gov:ic:cvenum:uias:personentitytype", "UIAS/Schema/UIAS/CVEGenerated/CVEnumUIASPersonEntityType.xsd"),
    ("urn:us:gov:ic:cvenum:uias:schematype", "UIAS/Schema/UIAS/CVEGenerated/CVEnumUIASSchemaType.xsd"),
    ("urn:us:gov:ic:cvenum:uias:securitymarktype", "UIAS/Schema/UIAS/CVEGenerated/CVEnumUIASSecurityMarkType.xsd"),
    ("urn:us:gov:ic:cvenum:unece20:measure", "DED/Schema/DED/CVEGenerated/CVEnumUNECE20UnitsOfMeasure.xsd"),
    ("urn:us:gov:ic:cvenum:usagency:agencyacronym", "USAgency/Schema/USAgency/CVEGenerated/CVEnumUSAgencyAcronym.xsd"),
    ("urn:us:gov:ic:cvenum:usagency:auditRoutingOrganization", "USAgency/Schema/USAgency/CVEGenerated/CVEnumAuditRoutingOrg.xsd"),
    ("urn:us:gov:ic:cvenum:usagency:auditRoutingUnique", "USAgency/Schema/USAgency/CVEGenerated/CVEnumAuditRoutingUnique.xsd"),
    ("urn:us:gov:ic:cvenum:usagency:usgovagencyacronym", "USAgency/Schema/USAgency/CVEGenerated/CVEnumUSGOVAgencyAcronym.xsd"),
    ("urn:us:gov:ic:cvenum:virt:network", "VIRT/Schema/VIRT/CVEGenerated/CVEnumVIRTNetworkName.xsd"),
    ("urn:us:gov:ic:ded", "DED/Schema/DED/DED.xsd"),
    ("urn:us:gov:ic:digitalhazmat", "DHZM/Schema/DHZM/DHZM-guard.xsd"),
    ("urn:us:gov:ic:edh", "IC-EDH/Schema/IC-EDH/IC-EDH.xsd"),
    ("urn:us:gov:ic:erm", "ERM/Schema/ERM/ERM_XML.xsd"),
    ("urn:us:gov:ic:fineaccesscontrol", "FAC/Schema/FAC/FineAccessControl.xsd"),
    ("urn:us:gov:ic:icgenc", "IC-GENC/Schema/IC-GENC/IC-GENC.xsd"),
    ("urn:us:gov:ic:icms", "ITS-OM/Schema/ITS-OM/ITS-OM.xsd"),
    ("urn:us:gov:ic:id", "IC-ID/Schema/IC-ID/IC-ID.xsd"),
    ("urn:us:gov:ic:intdis", "INTDIS/Schema/INTDIS/IntelDiscipline.xsd"),
    ("urn:us:gov:ic:irm", "IRM/Schema/IRM/IC-IRM.xsd"),
    ("urn:us:gov:ic:ism", "AUTHCAT/CVE/CveSchema/ISM/IC-ISM.xsd"),
    ("urn:us:gov:ic:its", "ITS-MS/Schema/ITS-MS/ITS-MS.xsd"),
    ("urn:us:gov:ic:lic", "LIC/Schema/LIC/LIC.xsd"),
    ("urn:us:gov:ic:mac", "MAC/Schema/MAC/MAC-XML.xsd"),
    ("urn:us:gov:ic:mime", "MIME/Schema/MIME/MIME.xsd"),
    ("urn:us:gov:ic:mn", "MN/Schema/MN/MN.xsd"),
    ("urn:us:gov:ic:ntk", "NTK/Schema/NTK/IC-NTK.xsd"),
    ("urn:us:gov:ic:pm", "PM/Schema/PM/PM.xsd"),
    ("urn:us:gov:ic:pma", "PMA/Schema/PMA/PMA-XML.xsd"),
    ("urn:us:gov:ic:revrecall", "RevRecall/Schema/RevRecall/RevRecall_XML.xsd"),
    ("urn:us:gov:ic:role", "ROLE/Schema/ROLE/ROLE.xsd"),
    ("urn:us:gov:ic:rr", "RR-SM/Schema/RR-SM/IC-RR-SM-REST.xsd"),
    ("urn:us:gov:ic:sf", "IC-SF/Schema/IC-SF/IC-SF.xsd"),
    ("urn:us:gov:ic:sf:hashverification", "IC-SF/Schema/IC-SF/HashVerification.xsd"),
    ("urn:us:gov:ic:taxonomy:catt:tetragraph", "ISMCAT/Schema/ISMCAT/Tetragraph.xsd"),
    ("urn:us:gov:ic:taxonomy:mnt:issue", "MNT/Schema/MNT/Issue.xsd"),
    ("urn:us:gov:ic:taxonomy:mnt:region", "MNT/Schema/MNT/Region.xsd"),
    ("urn:us:gov:ic:tdf", "BASE-TDF/Schema/BASE-TDF/BASE-TDF.xsd"),
    ("urn:us:gov:ic:uias", "UIAS/Schema/UIAS/UIAS.xsd"),
    ("urn:us:gov:ic:uiassaml", "UIAS/Schema/UIAS/UIAS_SAML.xsd"),
    ("urn:us:gov:ic:usagency", "USAgency/Schema/USAgency/USAgency.xsd"),
    ("urn:us:gov:ic:virt", "VIRT/Schema/VIRT/VIRT.xsd"),
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
    fn ismcat_package_present() {
        assert!(package("ISMCAT").is_dir());
    }

    #[test]
    fn namespace_table_is_sorted() {
        for w in NAMESPACE_TO_PATH.windows(2) {
            assert!(w[0].0 < w[1].0);
        }
    }

    #[test]
    fn resolve_known_namespace() {
        let p = resolve_namespace("urn:us:gov:ic:ismcat").unwrap();
        assert!(p.exists());
    }

    #[test]
    fn unknown_namespace_returns_none() {
        assert!(resolve_namespace("urn:not-real:nope").is_none());
    }

    #[test]
    fn verify_known_file() {
        // Pick a stable file likely to be present.
        verify_file("AUTHCAT/Schema/AUTHCAT/AuthorityCategory.xsd")
            .expect("AUTHCAT XSD should match its manifest hash");
    }

    #[test]
    fn manifest_digest_const_is_64_hex_chars() {
        assert_eq!(MANIFEST_DIGEST.len(), 64);
        assert!(MANIFEST_DIGEST.chars().all(|c| c.is_ascii_hexdigit()));
    }

    // verify_integrity() walks ~14k files; gate behind --ignored so we don't
    // pay the cost on every cargo test.
    #[test]
    #[ignore]
    fn verify_full_tree() {
        match verify_integrity() {
            Ok(n) => assert_eq!(n, 14632),
            Err(e) => panic!("{}", e),
        }
    }
}
