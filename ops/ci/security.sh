#!/usr/bin/env bash
# Security lane: the full supply-chain posture in one operational entrypoint.
# Delegates to the canonical wrapper tools/security-lane.sh, which runs secret
# scanning (gitleaks detect), dependency vulnerability scanning (cargo audit),
# SBOM/provenance (syft + cosign), and workflow linting (actionlint + zizmor).
# The same lane runs locally via `just security`.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$REPO_ROOT"

mkdir -p target/jankurai/security
log "security lane: tools/security-lane.sh (gitleaks + cargo audit + sbom + workflow lint)"
bash tools/security-lane.sh
