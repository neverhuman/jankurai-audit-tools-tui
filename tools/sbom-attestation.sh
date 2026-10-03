#!/usr/bin/env bash
# GitHub Actions OIDC SBOM attestation, moved out of tools/security-lane.sh.
# GitHub is now a publishing mirror and runs no workflows, so nothing invokes
# this script. It stays until key-based release signing replaces it.
set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Bind the SBOM to the actual locked build input. CI signs with its hosted-runner
# OIDC identity; local contributors use cosign's interactive identity provider.
cosign attest-blob --yes --type cyclonedx \
  --predicate target/jankurai/security/sbom.json \
  --bundle target/jankurai/security/sbom-attestation.sigstore.bundle Cargo.lock
identity="https://github.com/${GITHUB_REPOSITORY:-neverhuman/jankurai-tools-tui}/.github/workflows/ci.yml@${GITHUB_REF:-refs/heads/main}"
cosign verify-blob-attestation Cargo.lock --type cyclonedx \
  --bundle target/jankurai/security/sbom-attestation.sigstore.bundle \
  --certificate-identity "$identity" \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
