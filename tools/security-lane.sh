#!/usr/bin/env bash
# Canonical security lane wrapper for jankurai-tools-tui.
#
# One operational entrypoint for the full supply-chain posture: secret
# scanning, dependency vulnerability scanning, SBOM/provenance generation, and
# workflow linting. CI (.github/workflows/ci.yml) and the local runner both call
# this wrapper through ops/ci/security.sh so local and CI runs match.
# Each executed tool emits a `jankurai-security-step=` row for the evidence
# envelope. cargo-deny is not invoked here because this repo has no deny.toml.
set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p target/jankurai/security

run_step() {
    local label="$1"
    local tool="$2"
    local shell_command="$3"
    local advisory="$4"
    shift 4
    set +e
    "$@"
    local exit_code=$?
    set -e
    local status="ran"
    if [[ ${exit_code} -ne 0 ]]; then
        status="failed"
    fi
    printf 'jankurai-security-step={"label":"%s","tool":"%s","shell_command":"%s","status":"%s","advisory":%s,"exit_code":%d}\n' \
        "${label}" "${tool}" "${shell_command}" "${status}" "${advisory}" "${exit_code}"
    if [[ "${advisory}" == "true" ]]; then
        return 0
    fi
    return "${exit_code}"
}

echo "[security] secret scanning: gitleaks detect"
run_step gitleaks gitleaks 'gitleaks detect --source . --no-banner --redact' false \
    gitleaks detect --source . --no-banner --redact

echo "[security] dependency audit: cargo audit"
run_step cargo-audit cargo-audit 'cargo audit' false \
    cargo audit

echo "[security] SBOM / provenance: syft + cosign attestation"
run_step syft syft 'syft scan dir:.' false \
    syft scan dir:. --exclude './target/**' --exclude './.git/**' \
    -o cyclonedx-json=target/jankurai/security/sbom.json
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

echo "[security] workflow lint: actionlint + zizmor"
run_step actionlint actionlint 'actionlint' true \
    actionlint
run_step zizmor zizmor 'zizmor .github/workflows' false \
    zizmor .github/workflows
