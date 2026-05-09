// SPDX-License-Identifier: MIT-0 OR Unlicense

//! Metadata-only meta-crate for the ODNI public XML schema set.
//!
//! Carries no data files. Use this crate to:
//!
//! - Enumerate the ODNI packages shipped by this workspace ([`PACKAGES`]).
//! - Look up which package declares a given XML namespace
//!   ([`package_for_namespace`], [`relpath_for_namespace`]).
//! - Detect which packages are reachable via crates.io vs. git-only
//!   ([`is_published`], [`resolve_namespace_published`], [`PUBLISHED_PACKAGES`]).
//!
//! For actual schema files + integrity verification, depend on the
//! per-package crates `ism-{pkg}` (e.g. `ism-ismcat`, `ism-ic-edh`).
//! Each per-package crate exposes `data_root()`, `package_root()`,
//! `verify_integrity()`, and a `MANIFEST_DIGEST` const.
//!
//! Not every per-package crate is on crates.io. The workspace ships 59 of
//! them, but only the subset listed in `tools/published.toml` is published
//! (and exposed via [`PUBLISHED_PACKAGES`]). Consumers running in environments
//! that can only reach crates.io (e.g. mirrored builds) should call
//! [`resolve_namespace_published`] instead of [`resolve_namespace`] to fail
//! loudly when codegen targets a git-only package.
//!
//! # Example
//!
//! ```no_run
//! // In a consumer's build.rs
//! let (pkg, rel) = ism_data::resolve_namespace("urn:schema:guide:schema:ismcat")
//!     .expect("ISMCAT namespace is part of the ODNI set");
//! assert_eq!(pkg, "ISMCAT");
//! assert_eq!(rel, "Schema/ISMCAT/SchemaGuideSchema.xsd");
//! // Combine with the per-package crate's data_root():
//! //   let path = ism_ismcat::data_root().join(pkg).join(rel);
//! ```

#![deny(missing_docs)]

/// Resolve an XML namespace URI to `(package_name, relpath_within_data_root)`.
///
/// Returns `None` if the namespace is not part of the ODNI schema set
/// (e.g. upstream W3C namespaces that aren't redistributed by ODNI, or
/// a typo).
///
/// `relpath_within_data_root` does NOT include the package name prefix —
/// combine with the per-package crate's `data_root()` joined with the
/// package name (or `package_root()`) to produce a filesystem path:
///
/// ```no_run
/// if let Some((pkg, rel)) = ism_data::resolve_namespace("urn:schema:guide:schema:ismcat") {
///     // rel = "Schema/ISMCAT/SchemaGuideSchema.xsd"
///     // path = ism_ismcat::package_root().join(rel)
/// }
/// ```
pub fn resolve_namespace(uri: &str) -> Option<(&'static str, &'static str)> {
    NAMESPACE_TO_PACKAGE
        .binary_search_by_key(&uri, |&(ns, _, _)| ns)
        .ok()
        .map(|i| (NAMESPACE_TO_PACKAGE[i].1, NAMESPACE_TO_PACKAGE[i].2))
}

/// Return just the package name that declares `uri`, or `None`.
pub fn package_for_namespace(uri: &str) -> Option<&'static str> {
    resolve_namespace(uri).map(|(pkg, _)| pkg)
}

/// Return just the relpath (within the package's data root) for `uri`, or `None`.
pub fn relpath_for_namespace(uri: &str) -> Option<&'static str> {
    resolve_namespace(uri).map(|(_, rel)| rel)
}

/// Iterate over every `(namespace, package, relpath)` known to the workspace.
pub fn known_namespaces() -> impl Iterator<Item = (&'static str, &'static str, &'static str)> {
    NAMESPACE_TO_PACKAGE.iter().copied()
}

/// Return the cargo crate name for a given ODNI package.
///
/// e.g. `crate_name_for("ISMCAT") == "ism-ismcat"`,
/// `crate_name_for("IC-Docbook") == "ism-ic-docbook"`.
///
/// Special case: the ISM package's crate is named `ism` (not `ism-ism`).
/// The `ism` crate name was available on crates.io and the doubled prefix
/// reads awkwardly, so the canonical ISM crate skips the prefix.
pub fn crate_name_for(package: &str) -> Option<String> {
    if !PACKAGES.contains(&package) {
        return None;
    }
    Some(match package {
        "ISM" => "ism".to_string(),
        _ => format!("ism-{}", package.to_ascii_lowercase()),
    })
}

/// Returns `true` if `package` ships a per-package crate on crates.io.
///
/// Use this in build scripts that want to fail loudly when codegen targets a
/// namespace whose package is git-only (and therefore not reachable from
/// crates.io-mirrored environments). Driven by `tools/published.toml`.
pub fn is_published(package: &str) -> bool {
    PUBLISHED_PACKAGES.binary_search(&package).is_ok()
}

/// Like [`resolve_namespace`], but returns `None` when the namespace's
/// package is not on crates.io. Use to constrain codegen to crates.io-
/// reachable packages.
///
/// ```no_run
/// // In a build.rs running in a crates.io-only environment:
/// let (pkg, rel) = ism_data::resolve_namespace_published("urn:us:gov:ic:edh")
///     .expect("IC-EDH is published to crates.io");
/// // ...
/// ```
pub fn resolve_namespace_published(uri: &str) -> Option<(&'static str, &'static str)> {
    let (pkg, rel) = resolve_namespace(uri)?;
    is_published(pkg).then_some((pkg, rel))
}

/// Names of the ODNI packages shipped under `data/`.
///
/// Each name corresponds to a per-package crate `ism-{lowercased}`
/// (e.g. `ISMCAT` -> `ism-ismcat`, `IC-Docbook` -> `ism-ic-docbook`),
/// with one special case: `ISM` -> `ism` (the doubled prefix `ism-ism`
/// reads awkwardly and the `ism` crate name was available on crates.io).
/// See [`crate_name_for`].
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
    "ISM",
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

/// Names of ODNI packages currently published to crates.io as `ism-{lower}`
/// crates, sorted for binary search. Subset of [`PACKAGES`].
///
/// An empty slice means *no per-package crates* are on crates.io yet — only
/// the meta crate (`ism-data`) is — and consumers must use git dependencies
/// for any per-package crate they need. Driven by `tools/published.toml`;
/// regenerated by `tools/sync_published.py`. Do not edit by hand.
// ----- BEGIN GENERATED: PUBLISHED_PACKAGES -----
pub const PUBLISHED_PACKAGES: &[&str] = &[
    "IC-GENC",
    "ISM",
    "ISMCAT",
];
// ----- END GENERATED: PUBLISHED_PACKAGES -----

/// Sorted (namespace, package, relpath under that package) triples.
/// 235 entries.
///
/// The canonical home of `urn:us:gov:ic:ism` and every
/// `urn:us:gov:ic:cvenum:ism:*` namespace is the `ISM` package; copies
/// in `AUTHCAT`, `FAC`, `RR-SM`, etc. are bundled build dependencies and
/// are not surfaced through this table. Two `urn:us:gov:ic:cvenum:ism:*`
/// namespaces remain mapped to RR-SM (`ownerproducer`, `relto`,
/// `fgiopen`, `fgiprotected`) because the corresponding XSDs are
/// RR-SM-only and absent from the ISM zip.
const NAMESPACE_TO_PACKAGE: &[(&str, &str, &str)] = &[
    ("http://docbook.org/ns/docbook", "IC-Docbook", "XSL/IC-Docbook/docbook-xsl-1.79.2/slides/schema/xsd/docbook.xsd"),
    ("http://docbook.org/ns/docbook-slides", "IC-Docbook", "XSL/IC-Docbook/docbook-xsl-1.79.2/slides/schema/xsd/slides.xsd"),
    ("http://metadata.dod.mil/mdr/ns/DDMS/3.0/", "AUDIT", "CVE/Schema/DDMS/DDMS-GeospatialCoverage.xsd"),
    ("http://www.opengis.net/gml/3.2", "AUDIT", "CVE/Schema/DDMS/DDMS-GML-Profile.xsd"),
    ("http://www.w3.org/1999/xlink", "AUDIT", "Schema/XLINK/XLink.xsd"),
    ("http://www.w3.org/2001/SMIL20/", "RR-SM", "Schema/w3/2001/SMIL20/smil20-4gml.xsd"),
    ("http://www.w3.org/2001/SMIL20/Language", "RR-SM", "Schema/w3/2001/SMIL20/smil20-language-4gml.xsd"),
    ("http://www.w3.org/XML/1998/namespace", "AUDIT", "Schema/W3C-XML/W3C-XML-Namespace.xsd"),
    ("urn:CellexReport", "DOMEX", "Schema/DOMEX/CellexReport.xsd"),
    ("urn:schema:guide:schema:cdsmanifest", "CDSM", "Schema/CDSM/SchemaGuideSchema.xsd"),
    ("urn:schema:guide:schema:digitalhazmat", "DHZM", "Schema/DHZM/SchemaGuideSchema.xsd"),
    ("urn:schema:guide:schema:irm", "IRM", "Schema/IRM/SchemaGuideSchema.xsd"),
    ("urn:schema:guide:schema:ismcat", "ISMCAT", "Schema/ISMCAT/SchemaGuideSchema.xsd"),
    ("urn:schema:guide:schema:its", "ITS-MS", "Schema/ITS-MS/SchemaGuideSchema.xsd"),
    ("urn:schema:guide:schema:mac", "MAC", "Schema/MAC/SchemaGuideSchema.xsd"),
    ("urn:schema:guide:schema:pma", "PMA", "Schema/PMA/SchemaGuideSchema.xsd"),
    ("urn:schema:guide:schema:pubs", "MNT", "Schema/MNT/SchemaGuideSchema.xsd"),
    ("urn:schema:guide:schema:rr", "RevRecall", "Schema/RevRecall/SchemaGuideSchema.xsd"),
    ("urn:us:gov:ic:arh", "ARH", "Schema/ARH/IC-ARH.xsd"),
    ("urn:us:gov:ic:audit", "AUDIT", "Schema/AUDIT/IC-AUDIT.xsd"),
    ("urn:us:gov:ic:audit-cvenum", "AUDIT", "Schema/AUDIT/CVEGeneratedTypes.xsd"),
    ("urn:us:gov:ic:authcat", "AUTHCAT", "Schema/AUTHCAT/AuthorityCategory.xsd"),
    ("urn:us:gov:ic:boe", "BOE", "Schema/BOE/BOE.xsd"),
    ("urn:us:gov:ic:cdsmanifest", "CDSM", "Schema/CDSM/CDSM-guard.xsd"),
    ("urn:us:gov:ic:cem", "CEM", "Schema/CEM/CEM-XML.xsd"),
    ("urn:us:gov:ic:common", "AUDIT", "Schema/IC-COMMON/IC-Common.xsd"),
    ("urn:us:gov:ic:cve", "AUTHCAT", "CVE/CveSchema/CVEXml.xsd"),
    ("urn:us:gov:ic:cve:v1", "AUDIT", "CVE/Schema/CVEXml.xsd"),
    ("urn:us:gov:ic:cvenum:authcat:authcattype", "AUTHCAT", "Schema/AUTHCAT/CVEGenerated/CVEnumAuthCatType.xsd"),
    ("urn:us:gov:ic:cvenum:boe:CVEnumBOEAuthorizationType", "BOE", "Schema/BOE/CVEGenerated/CVEnumBOEAuthorizationType.xsd"),
    ("urn:us:gov:ic:cvenum:boe:CVEnumBOEInformationTechnologyType", "BOE", "Schema/BOE/CVEGenerated/CVEnumBOEInformationTechnologyType.xsd"),
    ("urn:us:gov:ic:cvenum:boe:CVEnumBOESoftwareCategory", "BOE", "Schema/BOE/CVEGenerated/CVEnumBOESoftwareCategory.xsd"),
    ("urn:us:gov:ic:cvenum:boe:CVEnumBOESystemOwnershipType", "BOE", "Schema/BOE/CVEGenerated/CVEnumBOESystemOwnershipType.xsd"),
    ("urn:us:gov:ic:cvenum:boe:CVEnumBOESystemUserCategory", "BOE", "Schema/BOE/CVEGenerated/CVEnumBOESystemUserCategory.xsd"),
    ("urn:us:gov:ic:cvenum:cemxml:citycategory", "CEM", "Schema/CEM/CVEGenerated/CVEnumCemCityCategory.xsd"),
    ("urn:us:gov:ic:cvenum:cemxml:commdatatype", "CEM", "Schema/CEM/CVEGenerated/CVEnumCemCommDataType.xsd"),
    ("urn:us:gov:ic:cvenum:cemxml:identifiertype", "CEM", "Schema/CEM/CVEGenerated/CVEnumCemIdentifierType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityCombatOperations", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityCombatOperations.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityCommunications", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityCommunications.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityCriminalActivities", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityCriminalActivities.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityFinance", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityFinance.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityHostageOperations", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityHostageOperations.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityIndividual", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityIndividual.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityPersonnelManagement", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityPersonnelManagement.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityPlanningGeneral", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityPlanningGeneral.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityPropagandaProductionandDistribution", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityPropagandaProductionandDistribution.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityRecruitmentOperations", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityRecruitmentOperations.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityReligious", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityReligious.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityWeaponsCyber", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityWeaponsCyber.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityWeaponsImprovised", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityWeaponsImprovised.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityWeaponsManufactured", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityWeaponsManufactured.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXActivityWeaponsofMassDestruction", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXActivityWeaponsofMassDestruction.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAffiliationTypeType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXAffiliationTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyCIA", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyCIA.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyDHS", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyDHS.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyDIA", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyDIA.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyDOD", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyDOD.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyDOJ", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyDOJ.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyFBI", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyFBI.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyNSA", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyNSA.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyOtherUSG", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyOtherUSG.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyUSA", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyUSA.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyUSAF", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyUSAF.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyUSMC", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyUSMC.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXAgencyUSN", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXAgencyUSN.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXCitizenshipStatusType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXCitizenshipStatusType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXCollectingUnitIDTypeType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXCollectingUnitIDTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXDispositionType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXDispositionType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXDocumentType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXDocumentType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXEducationDegreeType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXEducationDegreeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXEducationLevelType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXEducationLevelType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXEntityMethodOfExtractionType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXEntityMethodOfExtractionType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXEventTypeType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXEventTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXFileType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXFileType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXFinancialAccountTypeType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXFinancialAccountTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXFinancialTransactionTypeType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXFinancialTransactionTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXFisaType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXFisaType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXFlightTypeType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXFlightTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXHashDigestTypeType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXHashDigestTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXImageSizeTypeType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXImageSizeTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXLegalTitleType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXLegalTitleType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXLicenseTypeType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXLicenseTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXMediaType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXMediaType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXMembershipIdentificationTypeType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXMembershipIdentificationTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXMicroCollectionLocationDescriptorTypeType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXMicroCollectionLocationDescriptorTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXNumberOfFilesTypeType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXNumberOfFilesTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXOrganizationNameTypeType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXOrganizationNameTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXOrganizationTypeType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXOrganizationTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXPhysicalAttributeTypeType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXPhysicalAttributeTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXRelationshipNatureType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXRelationshipNatureType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXRelationshipTypeType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXRelationshipTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXTitleTypeType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXTitleTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXTranslationPriorityType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXTranslationPriorityType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXTranslationStatusType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXTranslationStatusType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXTranslationType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXTranslationType.xsd"),
    ("urn:us:gov:ic:cvenum:domex:CVEnumDOMEXTravelTypeType", "DOMEX", "Schema/DOMEX/CVEGenerated/CVEnumDOMEXTravelTypeType.xsd"),
    ("urn:us:gov:ic:cvenum:erm:holdCategory", "ERM", "Schema/ERM/CVEGenerated/CVEnumERMHoldCategory.xsd"),
    ("urn:us:gov:ic:cvenum:fac:fineaccesscontroltype", "FAC", "Schema/FAC/CVEGenerated/CVEnumFineAccessControlType.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country", "IC-GENC", "Schema/IC-GENC/CVEGenerated/CVEnumGENCCountryCode.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:33", "IC-GENC", "Schema/IC-GENC/CVEGenerated/CVEnumGeGENC3ed3.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:331", "IC-GENC", "Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-1.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:3310", "IC-GENC", "Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-10.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:3311", "IC-GENC", "Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-11.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:332", "IC-GENC", "Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-2.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:333", "IC-GENC", "Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-3.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:334", "IC-GENC", "Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-4.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:335", "IC-GENC", "Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-5.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:336", "IC-GENC", "Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-6.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:337", "IC-GENC", "Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-7.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:338", "IC-GENC", "Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-8.xsd"),
    ("urn:us:gov:ic:cvenum:genc:country:339", "IC-GENC", "Schema/IC-GENC/CVEGenerated/CVEnumGeGENC33-9.xsd"),
    ("urn:us:gov:ic:cvenum:genc:subdivision", "IC-GENC", "Schema/IC-GENC/CVEGenerated/CVEnumGENCSubDivisionCode.xsd"),
    ("urn:us:gov:ic:cvenum:intdis:inteldiscipline", "INTDIS", "Schema/INTDIS/CVEGenerated/CVEnumIntelDiscipline.xsd"),
    ("urn:us:gov:ic:cvenum:intdis:inteldiscipline:component", "INTDIS", "Schema/INTDIS/CVEGenerated/CVEnumIntelDisciplineComponent.xsd"),
    ("urn:us:gov:ic:cvenum:intdis:inteldiscipline:component:technique", "INTDIS", "Schema/INTDIS/CVEGenerated/CVEnumIntelDisciplineComponentTechnique.xsd"),
    ("urn:us:gov:ic:cvenum:irm:activity", "IRM", "Schema/IRM/CVEGenerated/CVEnumIRMActivity.xsd"),
    ("urn:us:gov:ic:cvenum:irm:complies:usa", "IRM", "Schema/IRM/CVEGenerated/CVEnumIRMCompliesWithUSA.xsd"),
    ("urn:us:gov:ic:cvenum:irm:coverage:iso3166:digraph", "IRM", "Schema/IRM/CVEGenerated/CVEnumIRMCoverageISO3166Digraph.xsd"),
    ("urn:us:gov:ic:cvenum:irm:coverage:precedence", "IRM", "Schema/IRM/CVEGenerated/CVEnumIRMCoveragePrecedence.xsd"),
    ("urn:us:gov:ic:cvenum:irm:executableindicator", "IRM", "Schema/IRM/CVEGenerated/CVEnumIRMExecutableIndicator.xsd"),
    ("urn:us:gov:ic:cvenum:irm:iso639-2:trigraph", "IRM", "Schema/IRM/CVEGenerated/CVEnumIRMISO639-2Trigraph.xsd"),
    ("urn:us:gov:ic:cvenum:irm:iso639-3:trigraph", "IRM", "Schema/IRM/CVEGenerated/CVEnumIRMISO639-3Trigraph.xsd"),
    ("urn:us:gov:ic:cvenum:irm:iso639:digraph", "IRM", "Schema/IRM/CVEGenerated/CVEnumIRMISO639Digraph.xsd"),
    ("urn:us:gov:ic:cvenum:irm:language:qualifier", "IRM", "Schema/IRM/CVEGenerated/CVEnumIRMCompoundLanguageQualifierType.xsd"),
    ("urn:us:gov:ic:cvenum:irm:maliciouscodeindicator", "IRM", "Schema/IRM/CVEGenerated/CVEnumIRMMaliciousCodeIndicator.xsd"),
    ("urn:us:gov:ic:cvenum:irm:positive:intel", "IRM", "Schema/IRM/CVEGenerated/CVEnumIRMPositiveIntel.xsd"),
    ("urn:us:gov:ic:cvenum:irm:waterBody", "IRM", "Schema/IRM/CVEGenerated/CVEnumIRMWaterBody.xsd"),
    ("urn:us:gov:ic:cvenum:ism:25x", "ISM", "Schema/ISM/CVEGenerated/CVEnumISM25X.xsd"),
    ("urn:us:gov:ic:cvenum:ism:HighWaterNATO", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMHighWaterNATO.xsd"),
    ("urn:us:gov:ic:cvenum:ism:atomicEnergyMarkings", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMAtomicEnergyMarkings.xsd"),
    ("urn:us:gov:ic:cvenum:ism:attributes", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMAttributes.xsd"),
    ("urn:us:gov:ic:cvenum:ism:classification:all", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMClassificationAll.xsd"),
    ("urn:us:gov:ic:cvenum:ism:classification:us", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMClassificationUS.xsd"),
    ("urn:us:gov:ic:cvenum:ism:complieswith", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMCompliesWith.xsd"),
    ("urn:us:gov:ic:cvenum:ism:cuibasic", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMCUIBasic.xsd"),
    ("urn:us:gov:ic:cvenum:ism:cuispecified", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMCUISpecified.xsd"),
    ("urn:us:gov:ic:cvenum:ism:dissem", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMDissem.xsd"),
    ("urn:us:gov:ic:cvenum:ism:dissem:commingled", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMDissemCommingled.xsd"),
    ("urn:us:gov:ic:cvenum:ism:dissem:cui", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMDissemCui.xsd"),
    ("urn:us:gov:ic:cvenum:ism:dissem:icrm", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMDissemIcrm.xsd"),
    ("urn:us:gov:ic:cvenum:ism:elements", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMElements.xsd"),
    ("urn:us:gov:ic:cvenum:ism:exemptfrom", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMExemptFrom.xsd"),
    ("urn:us:gov:ic:cvenum:ism:fgiopen", "RR-SM", "Schema/ISM/CVEGenerated/CVEnumISMFGIOpen.xsd"),
    ("urn:us:gov:ic:cvenum:ism:fgiprotected", "RR-SM", "Schema/ISM/CVEGenerated/CVEnumISMFGIProtected.xsd"),
    ("urn:us:gov:ic:cvenum:ism:nonic", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMNonIC.xsd"),
    ("urn:us:gov:ic:cvenum:ism:nonuscontrols", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMNonUSControls.xsd"),
    ("urn:us:gov:ic:cvenum:ism:notice", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMNotice.xsd"),
    ("urn:us:gov:ic:cvenum:ism:noticeprose", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMNoticeProse.xsd"),
    ("urn:us:gov:ic:cvenum:ism:ownerproducer", "RR-SM", "Schema/ISM/CVEGenerated/CVEnumISMOwnerProducer.xsd"),
    ("urn:us:gov:ic:cvenum:ism:pocType", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMPocType.xsd"),
    ("urn:us:gov:ic:cvenum:ism:relto", "RR-SM", "Schema/ISM/CVEGenerated/CVEnumISMRelTo.xsd"),
    ("urn:us:gov:ic:cvenum:ism:sar", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMSAR.xsd"),
    ("urn:us:gov:ic:cvenum:ism:scicontrols", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMSCIControls.xsd"),
    ("urn:us:gov:ic:cvenum:ism:secondbannerline", "ISM", "Schema/ISM/CVEGenerated/CVEnumISMSecondBannerLine.xsd"),
    ("urn:us:gov:ic:cvenum:ismcat:fgiopen", "ISMCAT", "Schema/ISMCAT/CVEGenerated/CVEnumISMCATFGIOpen.xsd"),
    ("urn:us:gov:ic:cvenum:ismcat:fgiprotected", "ISMCAT", "Schema/ISMCAT/CVEGenerated/CVEnumISMCATFGIProtected.xsd"),
    ("urn:us:gov:ic:cvenum:ismcat:ownerproducer", "ISMCAT", "Schema/ISMCAT/CVEGenerated/CVEnumISMCATOwnerProducer.xsd"),
    ("urn:us:gov:ic:cvenum:ismcat:relto", "ISMCAT", "Schema/ISMCAT/CVEGenerated/CVEnumISMCATRelTo.xsd"),
    ("urn:us:gov:ic:cvenum:ismcat:responsibleentity", "ISMCAT", "Schema/ISMCAT/CVEGenerated/CVEnumISMCATResponsibleEntity.xsd"),
    ("urn:us:gov:ic:cvenum:ismcat:tetragraph", "ISMCAT", "Schema/ISMCAT/CVEGenerated/CVEnumISMCATTetragraph.xsd"),
    ("urn:us:gov:ic:cvenum:itsms:fabric", "ITS-MS", "Schema/ITS-MS/CVEGenerated/CVEnumITSMSFabric.xsd"),
    ("urn:us:gov:ic:cvenum:lic:license", "LIC", "Schema/LIC/CVEGenerated/CVEnumLicLicense.xsd"),
    ("urn:us:gov:ic:cvenum:mac:collectionType", "MAC", "Schema/MAC/CVEGenerated/CVEnumMacCollectionType.xsd"),
    ("urn:us:gov:ic:cvenum:mime:type", "MIME", "Schema/MIME/CVEGenerated/CVEnumMIMEIANAType.xsd"),
    ("urn:us:gov:ic:cvenum:mn:issue", "MN", "Schema/MN/CVEGenerated/CVEnumMNIssue.xsd"),
    ("urn:us:gov:ic:cvenum:mn:region", "MN", "Schema/MN/CVEGenerated/CVEnumMNRegion.xsd"),
    ("urn:us:gov:ic:cvenum:ntk:accesspolicy", "NTK", "Schema/NTK/CVEGenerated/CVEnumNTKAccessPolicy.xsd"),
    ("urn:us:gov:ic:cvenum:ntk:profiledes", "NTK", "Schema/NTK/CVEGenerated/CVEnumNTKProfileDes.xsd"),
    ("urn:us:gov:ic:cvenum:pm:actor", "PM", "Schema/PM/CVEGenerated/CVEnumPMActor.xsd"),
    ("urn:us:gov:ic:cvenum:pm:location", "PM", "Schema/PM/CVEGenerated/CVEnumPMLocation.xsd"),
    ("urn:us:gov:ic:cvenum:pm:nonstateactors", "PM", "Schema/PM/CVEGenerated/CVEnumPMNonStateActors.xsd"),
    ("urn:us:gov:ic:cvenum:pm:subject", "PM", "Schema/PM/CVEGenerated/CVEnumPMSubject.xsd"),
    ("urn:us:gov:ic:cvenum:revrecall:action", "RevRecall", "Schema/RevRecall/CVEGenerated/CVEnumRevRecallAction.xsd"),
    ("urn:us:gov:ic:cvenum:revrecall:type", "RevRecall", "Schema/RevRecall/CVEGenerated/CVEnumRevRecallType.xsd"),
    ("urn:us:gov:ic:cvenum:role:c2sfunction", "ROLE", "Schema/ROLE/CVEGenerated/CVEnumROLEC2SFunction.xsd"),
    ("urn:us:gov:ic:cvenum:role:c2sscope", "ROLE", "Schema/ROLE/CVEGenerated/CVEnumROLEC2SScope.xsd"),
    ("urn:us:gov:ic:cvenum:role:enterprise:role", "ROLE", "Schema/ROLE/CVEGenerated/CVEnumROLEEnterpriseRole.xsd"),
    ("urn:us:gov:ic:cvenum:role:namespace", "ROLE", "Schema/ROLE/CVEGenerated/CVEnumROLENamespace.xsd"),
    ("urn:us:gov:ic:cvenum:role:nebula:namedrole", "ROLE", "Schema/ROLE/CVEGenerated/CVEnumROLENebulaNamedRole.xsd"),
    ("urn:us:gov:ic:cvenum:role:paasfunction", "ROLE", "Schema/ROLE/CVEGenerated/CVEnumROLEPAASFunction.xsd"),
    ("urn:us:gov:ic:cvenum:role:paasscope", "ROLE", "Schema/ROLE/CVEGenerated/CVEnumROLEPAASScope.xsd"),
    ("urn:us:gov:ic:cvenum:tdf:hashalgorithm", "BASE-TDF", "Schema/BASE-TDF/CVEGenerated/CVEnumTDFHashAlgorithm.xsd"),
    ("urn:us:gov:ic:cvenum:tdf:signaturealgorithm", "BASE-TDF", "Schema/BASE-TDF/CVEGenerated/CVEnumTDFSignatureAlgorithm.xsd"),
    ("urn:us:gov:ic:cvenum:tdf:state", "BASE-TDF", "Schema/BASE-TDF/CVEGenerated/CVEnumTDFAppliesToState.xsd"),
    ("urn:us:gov:ic:cvenum:uias:attribute", "UIAS", "Schema/UIAS/CVEGenerated/CVEnumUIASAttribute.xsd"),
    ("urn:us:gov:ic:cvenum:uias:certificateauthority", "UIAS", "Schema/UIAS/CVEGenerated/CVEnumUIASCertificateAuthority.xsd"),
    ("urn:us:gov:ic:cvenum:uias:clearance", "UIAS", "Schema/UIAS/CVEGenerated/CVEnumUIASClearance.xsd"),
    ("urn:us:gov:ic:cvenum:uias:entitytype", "UIAS", "Schema/UIAS/CVEGenerated/CVEnumUIASEntityType.xsd"),
    ("urn:us:gov:ic:cvenum:uias:handlingControls", "UIAS", "Schema/UIAS/CVEGenerated/CVEnumUIASHandlingControls.xsd"),
    ("urn:us:gov:ic:cvenum:uias:lifecyclestatus", "UIAS", "Schema/UIAS/CVEGenerated/CVEnumUIASLifeCycleStatus.xsd"),
    ("urn:us:gov:ic:cvenum:uias:nonpersonentitytype", "UIAS", "Schema/UIAS/CVEGenerated/CVEnumUIASNonPersonEntityType.xsd"),
    ("urn:us:gov:ic:cvenum:uias:personentitytype", "UIAS", "Schema/UIAS/CVEGenerated/CVEnumUIASPersonEntityType.xsd"),
    ("urn:us:gov:ic:cvenum:uias:schematype", "UIAS", "Schema/UIAS/CVEGenerated/CVEnumUIASSchemaType.xsd"),
    ("urn:us:gov:ic:cvenum:uias:securitymarktype", "UIAS", "Schema/UIAS/CVEGenerated/CVEnumUIASSecurityMarkType.xsd"),
    ("urn:us:gov:ic:cvenum:unece20:measure", "DED", "Schema/DED/CVEGenerated/CVEnumUNECE20UnitsOfMeasure.xsd"),
    ("urn:us:gov:ic:cvenum:usagency:agencyacronym", "USAgency", "Schema/USAgency/CVEGenerated/CVEnumUSAgencyAcronym.xsd"),
    ("urn:us:gov:ic:cvenum:usagency:auditRoutingOrganization", "USAgency", "Schema/USAgency/CVEGenerated/CVEnumAuditRoutingOrg.xsd"),
    ("urn:us:gov:ic:cvenum:usagency:auditRoutingUnique", "USAgency", "Schema/USAgency/CVEGenerated/CVEnumAuditRoutingUnique.xsd"),
    ("urn:us:gov:ic:cvenum:usagency:usgovagencyacronym", "USAgency", "Schema/USAgency/CVEGenerated/CVEnumUSGOVAgencyAcronym.xsd"),
    ("urn:us:gov:ic:cvenum:virt:network", "VIRT", "Schema/VIRT/CVEGenerated/CVEnumVIRTNetworkName.xsd"),
    ("urn:us:gov:ic:ded", "DED", "Schema/DED/DED.xsd"),
    ("urn:us:gov:ic:digitalhazmat", "DHZM", "Schema/DHZM/DHZM-guard.xsd"),
    ("urn:us:gov:ic:edh", "IC-EDH", "Schema/IC-EDH/IC-EDH.xsd"),
    ("urn:us:gov:ic:erm", "ERM", "Schema/ERM/ERM_XML.xsd"),
    ("urn:us:gov:ic:fineaccesscontrol", "FAC", "Schema/FAC/FineAccessControl.xsd"),
    ("urn:us:gov:ic:icgenc", "IC-GENC", "Schema/IC-GENC/IC-GENC.xsd"),
    ("urn:us:gov:ic:icms", "ITS-OM", "Schema/ITS-OM/ITS-OM.xsd"),
    ("urn:us:gov:ic:id", "IC-ID", "Schema/IC-ID/IC-ID.xsd"),
    ("urn:us:gov:ic:intdis", "INTDIS", "Schema/INTDIS/IntelDiscipline.xsd"),
    ("urn:us:gov:ic:irm", "IRM", "Schema/IRM/IC-IRM.xsd"),
    ("urn:us:gov:ic:ism", "ISM", "Schema/ISM/IC-ISM.xsd"),
    ("urn:us:gov:ic:its", "ITS-MS", "Schema/ITS-MS/ITS-MS.xsd"),
    ("urn:us:gov:ic:lic", "LIC", "Schema/LIC/LIC.xsd"),
    ("urn:us:gov:ic:mac", "MAC", "Schema/MAC/MAC-XML.xsd"),
    ("urn:us:gov:ic:mime", "MIME", "Schema/MIME/MIME.xsd"),
    ("urn:us:gov:ic:mn", "MN", "Schema/MN/MN.xsd"),
    ("urn:us:gov:ic:ntk", "NTK", "Schema/NTK/IC-NTK.xsd"),
    ("urn:us:gov:ic:pm", "PM", "Schema/PM/PM.xsd"),
    ("urn:us:gov:ic:pma", "PMA", "Schema/PMA/PMA-XML.xsd"),
    ("urn:us:gov:ic:revrecall", "RevRecall", "Schema/RevRecall/RevRecall_XML.xsd"),
    ("urn:us:gov:ic:role", "ROLE", "Schema/ROLE/ROLE.xsd"),
    ("urn:us:gov:ic:rr", "RR-SM", "Schema/RR-SM/IC-RR-SM-REST.xsd"),
    ("urn:us:gov:ic:sf", "IC-SF", "Schema/IC-SF/IC-SF.xsd"),
    ("urn:us:gov:ic:sf:hashverification", "IC-SF", "Schema/IC-SF/HashVerification.xsd"),
    ("urn:us:gov:ic:taxonomy:catt:tetragraph", "ISMCAT", "Schema/ISMCAT/Tetragraph.xsd"),
    ("urn:us:gov:ic:taxonomy:mnt:issue", "MNT", "Schema/MNT/Issue.xsd"),
    ("urn:us:gov:ic:taxonomy:mnt:region", "MNT", "Schema/MNT/Region.xsd"),
    ("urn:us:gov:ic:tdf", "BASE-TDF", "Schema/BASE-TDF/BASE-TDF.xsd"),
    ("urn:us:gov:ic:uias", "UIAS", "Schema/UIAS/UIAS.xsd"),
    ("urn:us:gov:ic:uiassaml", "UIAS", "Schema/UIAS/UIAS_SAML.xsd"),
    ("urn:us:gov:ic:usagency", "USAgency", "Schema/USAgency/USAgency.xsd"),
    ("urn:us:gov:ic:virt", "VIRT", "Schema/VIRT/VIRT.xsd"),
    ("urn:us:mil:ces:metadata:domex", "DOMEX", "Schema/DOMEX/DOMEX.xsd"),
    ("urn:us:mil:ces:metadata:domex_identity", "DOMEX", "Schema/DOMEX/Identity.xsd"),
];

// --- tests ---

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn packages_table_has_60_entries() {
        assert_eq!(PACKAGES.len(), 60);
    }

    #[test]
    fn namespace_table_is_sorted() {
        for w in NAMESPACE_TO_PACKAGE.windows(2) {
            assert!(
                w[0].0 < w[1].0,
                "namespace table not sorted: {} >= {}",
                w[0].0,
                w[1].0
            );
        }
    }

    #[test]
    fn every_namespace_package_is_in_packages_list() {
        for &(uri, pkg, _) in NAMESPACE_TO_PACKAGE {
            assert!(
                PACKAGES.contains(&pkg),
                "namespace {uri} references unknown package {pkg}",
            );
        }
    }

    #[test]
    fn resolve_known_namespace() {
        let (pkg, rel) = resolve_namespace("urn:us:gov:ic:edh").unwrap();
        assert_eq!(pkg, "IC-EDH");
        assert_eq!(rel, "Schema/IC-EDH/IC-EDH.xsd");
    }

    #[test]
    fn resolve_ismcat_guide_namespace() {
        let (pkg, rel) = resolve_namespace("urn:schema:guide:schema:ismcat").unwrap();
        assert_eq!(pkg, "ISMCAT");
        assert_eq!(rel, "Schema/ISMCAT/SchemaGuideSchema.xsd");
    }

    #[test]
    fn unknown_namespace_returns_none() {
        assert!(resolve_namespace("urn:not-real:nope").is_none());
    }

    #[test]
    fn ism_namespace_lives_in_ism_package() {
        // urn:us:gov:ic:ism is the canonical ISM namespace; though
        // AUTHCAT, RR-SM, and others bundle copies of IC-ISM.xsd as build
        // dependencies, the canonical owner is the dedicated ISM package.
        assert_eq!(package_for_namespace("urn:us:gov:ic:ism"), Some("ISM"));
    }

    #[test]
    fn crate_name_kebab_lowercases_correctly() {
        assert_eq!(crate_name_for("ISMCAT").as_deref(), Some("ism-ismcat"));
        assert_eq!(
            crate_name_for("IC-Docbook").as_deref(),
            Some("ism-ic-docbook")
        );
        assert_eq!(crate_name_for("BASE-TDF").as_deref(), Some("ism-base-tdf"));
        assert_eq!(crate_name_for("not-a-package"), None);
    }

    #[test]
    fn crate_name_for_ism_special_cases_to_ism() {
        // The canonical ISM crate is named `ism`, not `ism-ism`.
        assert_eq!(crate_name_for("ISM").as_deref(), Some("ism"));
    }

    #[test]
    fn published_packages_is_sorted() {
        // Required for the binary_search in `is_published`.
        for w in PUBLISHED_PACKAGES.windows(2) {
            assert!(
                w[0] < w[1],
                "PUBLISHED_PACKAGES not sorted: {} >= {}",
                w[0],
                w[1]
            );
        }
    }

    #[test]
    fn every_published_package_is_a_known_package() {
        // Catches typos and stale entries after PACKAGES drift.
        for &pkg in PUBLISHED_PACKAGES {
            assert!(
                PACKAGES.contains(&pkg),
                "PUBLISHED_PACKAGES references unknown package {pkg}",
            );
        }
    }

    #[test]
    fn is_published_rejects_unknown_packages() {
        assert!(!is_published("not-a-package"));
        assert!(!is_published(""));
    }

    #[test]
    fn resolve_namespace_published_returns_none_for_unpublished() {
        // Pick any known namespace; if its package isn't in PUBLISHED_PACKAGES,
        // the helper must hide it. (When the published set is empty, every
        // resolution is filtered out.)
        if let Some((uri, pkg, _)) = NAMESPACE_TO_PACKAGE.first() {
            if !is_published(pkg) {
                assert!(resolve_namespace_published(uri).is_none());
            }
        }
        assert!(resolve_namespace_published("urn:not-real:nope").is_none());
    }

    #[test]
    fn resolve_namespace_published_agrees_with_resolve_when_published() {
        for &(uri, pkg, rel) in NAMESPACE_TO_PACKAGE {
            if is_published(pkg) {
                assert_eq!(resolve_namespace_published(uri), Some((pkg, rel)));
            }
        }
    }
}
