// SPDX-License-Identifier: MIT-0 OR Unlicense

//! Build-time integrity check for the IRM package.
//!
//! Re-hashes every file under `data/` and compares against
//! `data/_provenance/manifest.txt`. If a single file differs, this crate
//! refuses to compile — meaning any consumer that uses
//! `[build-dependencies] ism-irm = ...` cannot build with tampered
//! schemas.
//!
//! The check is opt-out via `--no-default-features` (the `verify-on-build`
//! feature is enabled by default).

use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader, Read};
use std::path::{Path, PathBuf};

use sha2::{Digest, Sha256};

fn main() {
    if env::var_os("CARGO_FEATURE_VERIFY_ON_BUILD").is_none() {
        return;
    }

    let manifest_dir =
        PathBuf::from(env::var_os("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR"));
    let data_dir = manifest_dir.join("data");
    let manifest_path = data_dir.join("_provenance/manifest.txt");
    let digest_path = data_dir.join("_provenance/manifest.sha256");

    println!("cargo:rerun-if-changed={}", manifest_path.display());
    println!("cargo:rerun-if-changed={}", digest_path.display());
    println!("cargo:rerun-if-env-changed=ISM_DATA_SKIP_VERIFY");

    if env::var_os("ISM_DATA_SKIP_VERIFY").is_some() {
        println!(
            "cargo:warning=ism-irm: integrity check SKIPPED (ISM_DATA_SKIP_VERIFY set)"
        );
        return;
    }

    let manifest_bytes = std::fs::read(&manifest_path).unwrap_or_else(|e| {
        panic!(
            "ism-irm: cannot read manifest.txt at {}: {}",
            manifest_path.display(),
            e
        )
    });
    let manifest_digest_actual = hex_digest(&manifest_bytes);
    let manifest_digest_expected = std::fs::read_to_string(&digest_path)
        .unwrap_or_else(|e| {
            panic!(
                "ism-irm: cannot read manifest.sha256 at {}: {}",
                digest_path.display(),
                e
            )
        })
        .trim()
        .to_owned();
    if manifest_digest_actual != manifest_digest_expected {
        panic!(
            "ism-irm: manifest.sha256 does not match SHA-256 of manifest.txt.\n\
             expected: {}\n\
             actual:   {}\n\
             Refusing to build — manifest itself appears tampered.",
            manifest_digest_expected, manifest_digest_actual,
        );
    }

    let reader = BufReader::new(std::io::Cursor::new(manifest_bytes));
    let mut checked: usize = 0;
    let mut errors: Vec<String> = Vec::new();
    for line in reader.lines() {
        let line = line.expect("read manifest line");
        if line.is_empty() {
            continue;
        }
        let (expected_sha, rel) = match line.split_once("  ") {
            Some(parts) => parts,
            None => {
                errors.push(format!("malformed manifest line: {:?}", line));
                continue;
            }
        };
        let path = data_dir.join(rel);
        match hash_file(&path) {
            Ok(actual_sha) => {
                if actual_sha != expected_sha {
                    errors.push(format!(
                        "{}\n    expected: {}\n    actual:   {}",
                        rel, expected_sha, actual_sha
                    ));
                }
            }
            Err(e) => {
                errors.push(format!("{}: {}", rel, e));
            }
        }
        checked += 1;
    }

    if !errors.is_empty() {
        let head: Vec<&String> = errors.iter().take(10).collect();
        let extra = if errors.len() > 10 {
            format!("\n  ...and {} more failure(s)", errors.len() - 10)
        } else {
            String::new()
        };
        panic!(
            "ism-irm: integrity check failed for {} of {} files.\n\
             First few:\n  {}{}\n\
             Refusing to build — data/ has been tampered with or is corrupted.",
            errors.len(),
            checked,
            head.iter()
                .map(|s| s.as_str())
                .collect::<Vec<_>>()
                .join("\n  "),
            extra,
        );
    }

    println!(
        "cargo:warning=ism-irm: verified {} files against manifest (digest {})",
        checked,
        &manifest_digest_actual[..16]
    );
}

fn hash_file(path: &Path) -> std::io::Result<String> {
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
    Ok(hex_digest_finalized(hasher))
}

fn hex_digest(bytes: &[u8]) -> String {
    let mut h = Sha256::new();
    h.update(bytes);
    hex_digest_finalized(h)
}

fn hex_digest_finalized(hasher: Sha256) -> String {
    let bytes = hasher.finalize();
    let mut s = String::with_capacity(bytes.len() * 2);
    for b in bytes {
        s.push_str(HEX[((b >> 4) & 0xf) as usize]);
        s.push_str(HEX[(b & 0xf) as usize]);
    }
    s
}

const HEX: [&str; 16] = [
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f",
];
