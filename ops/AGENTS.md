# ops Agent Instructions

This directory holds the pinned CI script entrypoints for jankurai-tools-tui.

## Owns

- `ops/ci/lib.sh` — shared helpers and pinned tool versions sourced by every lane.
- `ops/ci/required.sh` — lightweight gate: workspace metadata + tests.
- `ops/ci/fast.sh` — deterministic fast lane: `cargo check` + `cargo nextest`.
- `ops/ci/security.sh` — secret (`gitleaks`) + dependency (`cargo audit`) scanning.
- `ops/ci/audit.sh` — jankurai self-audit, writes `.jankurai/repo-score.{json,md}`.
- `ops/ci/tool-adoption.sh` — adopted jankurai tool lanes, evidence under `target/jankurai/`.
- `ops/ci/quality-gates.sh` — aggregate gate that runs the lanes above.

## Forbidden

- Do not inline lane logic into `.github/workflows/ci.yml`; the workflow must stay
  thin and delegate to `ops/ci/<lane>.sh` so local and CI runs match.
- Do not unpin a GitHub Action; every third-party `uses:` is pinned to a
  40-character commit SHA.
- Do not write durable product truth or generated output here.

## Proof lane

Changes under `ops/` route through `bash scripts/ci-local.sh required` (see
[`agent/test-map.json`](../agent/test-map.json)). The security lane is
`bash ops/ci/security.sh`.
