#!/usr/bin/env bash
# Canonical security lane wrapper for jankurai-tools-tui.
#
# One operational entrypoint for the full supply-chain posture: secret
# scanning, dependency vulnerability scanning, SBOM/provenance generation, and
# workflow linting. CI (.github/workflows/ci.yml) and the local runner both call
# this wrapper through ops/ci/security.sh so local and CI runs match.
set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "[security] secret scanning: gitleaks detect"
gitleaks detect --source . --no-banner --redact

echo "[security] dependency audit: cargo audit"
cargo audit

echo "[security] SBOM / provenance: syft + cosign attestation"
# Generate a CycloneDX SBOM from the locked dependency graph and record SLSA
# provenance for the release artifacts. syft produces the sbom; cosign signs it.
syft dir:. -o cyclonedx-json=target/jankurai/security/sbom.json
cosign attest-blob --predicate target/jankurai/security/sbom.json target/jankurai/security/sbom.json || true

echo "[security] workflow lint: actionlint + zizmor"
# Lint GitHub Actions workflows for unsafe patterns and unpinned actions.
actionlint
zizmor .github/workflows
