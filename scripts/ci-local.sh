#!/usr/bin/env bash
# Local CI runner. Routes each lane to the same ops/ci/<lane>.sh script that
# GitHub Actions runs, so a green local run means a green CI run.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

lane="${1:-required}"
case "$lane" in
  required)       bash ops/ci/required.sh ;;
  fast)           bash ops/ci/fast.sh ;;
  security)       bash ops/ci/security.sh ;;
  audit)          bash ops/ci/audit.sh ;;
  quality-gates)  bash ops/ci/quality-gates.sh ;;
  tool-adoption)  bash ops/ci/tool-adoption.sh ;;
  *) echo "usage: $0 {required|fast|security|audit|quality-gates|tool-adoption}" >&2; exit 2 ;;
esac
