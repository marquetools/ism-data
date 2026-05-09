<!--
SPDX-License-Identifier: MIT-0 OR Unlicense
-->

# ism

Vendored ODNI **ISM** (Information Security Marking) schema package, with
SHA-256 integrity verification at compile time.

Part of the [`ism-data`](https://github.com/marquetools/ism-data) workspace.

The ISM package is the canonical home of the `urn:us:gov:ic:ism` namespace
and every `urn:us:gov:ic:cvenum:ism:*` controlled-value enumeration —
classification levels, SCI controls, dissemination controls, SAR
identifiers, declassification exemptions, and so on. Many other ODNI
packages bundle copies of the ISM CVE files as build dependencies; this
crate is the canonical source.

## Use

```toml
# Cargo.toml
[build-dependencies]
ism = "20230609.0.0"
# or
ism = { git = "https://github.com/marquetools/ism-data", tag = "v..." }
```

```rust,ignore
// build.rs
let xsd = ism::package_root().join("Schema/ISM/IC-ISM.xsd");
println!("cargo:rerun-if-changed={}", xsd.display());

// CVE values (XML form, with codable values + descriptions)
let cve_xml = ism::package_root().join("CVE/ISM/CVEnumISMClassificationAll.xml");

// Schematron rules for cross-attribute validation
let sch = ism::package_root().join("Schematron/ISM/ISM_XML.sch");

// Resolve a namespace to the XSD that declares it
let xsd = ism::resolve_namespace("urn:us:gov:ic:ism")
    .expect("ISM namespace is declared by this package");
```

## What's in `data/ISM/`

```text
data/ISM/
  CVE/
    ISM/                  CVEnumISM*.xml + .json + .csv (CVE values)
    CveSchema/ISMCAT/     ISMCAT subset bundled by ODNI as a build dep
  Schema/
    ISM/                  IC-ISM.xsd + CVEGenerated/CVEnumISM*.xsd, .rng, .rnc
                          IC-ARH.xsd, IC-NTK.xsd (bundled deps from ARH / NTK)
  Schematron/
    ISM/                  ISM_XML.sch + Lib/*.sch + Rules/*.sch
```

The bundled `CVE/CveSchema/ISMCAT/` and `Schema/ISM/IC-{ARH,NTK}.xsd` are
copies ODNI ships inside `ISM-Public-Standalone.zip` so relative
`xs:import schemaLocation` references resolve. They are **not** the
canonical home of the ISMCAT, ARH, or NTK namespaces — depend on
`ism-ismcat`, `ism-arh`, or `ism-ntk` for those.

## Integrity

`build.rs` re-hashes every file under `data/` against the baked
`data/_provenance/manifest.txt` at the consumer's compile time. A single
modified byte refuses the build.

The `MANIFEST_DIGEST` const exposes the SHA-256 of the manifest itself —
pin it in your release notes for external attestation.

## License

Schemas: U.S. Government public-domain works.
Crate scaffolding: MIT-0 OR Unlicense.
