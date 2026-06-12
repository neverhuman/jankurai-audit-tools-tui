# Testing

Testing is routed proof. Agents should not guess which tests matter; they route
through [`agent/test-map.json`](../agent/test-map.json) to the smallest lane that
proves a change.

## Lanes

| Lane | Purpose |
| --- | --- |
| `required` | lightweight gate: `cargo metadata` resolves and the workspace test suite passes |
| `fast` | deterministic local proof for most edits: `cargo check --workspace --locked` then `cargo nextest run --workspace` |
| `security` | secret scanning (`gitleaks`) plus dependency vulnerability scanning (`cargo audit`) |
| `audit` | jankurai repo score and hard-rule findings, written to `.jankurai/repo-score.{json,md}` |
| `tool-adoption` | run the adopted jankurai tool lanes and emit evidence under `target/jankurai/` |
| `full` | release/merge gate: `just check` (format, lint, fast, security, self-audit) |

Each lane is defined in [`agent/proof-lanes.toml`](../agent/proof-lanes.toml) and
runnable both locally (`bash scripts/ci-local.sh <lane>` or `just <lane>`) and in
CI (`ops/ci/<lane>.sh`), so a green local run means a green CI run.

## Test surface

The Rust surface carries two kinds of tests:

- **Integration tests** under `crates/tuiwright/tests/` drive the
  `tuiwright-demo` example through a real pseudo-terminal: spawning, waiting for
  text, pressing keys, screenshots, GIF recording, locators, and screen
  assertions (`smoke.rs`).
- **Property tests** under `crates/tuiwright/tests/encoding_props.rs` use
  `proptest` to check invariants of the deterministic input-encoding surface
  (`encode_key`, `encode_text`, `encode_paste`, `encode_sgr_mouse`,
  `encode_sgr_scroll`) over generated inputs.

Both run through `cargo nextest run --workspace` (the `fast` lane).

## Repair receipts and telemetry

When a proof lane fails, keep the next agent on the shortest possible rerun path.

- Emit structured errors instead of only free-form prose whenever the tool can do
  it. The library uses `thiserror`/`anyhow` typed error surfaces so failures name
  the cause, not just a stack trace.
- Record the failing command, exit code, changed paths, artifact paths, and rerun
  command in the receipt.
- Prefer typed telemetry or JSON envelopes under `target/jankurai/` over ad hoc
  log spam. The `tuiwright` CLI writes JSONL traces for the same reason: machine-
  readable evidence beats prose.
- Surface the repair hint, docs URL, and common fixes together so the next rerun
  is obvious. Each `agent/test-map.json` entry names the exact proof command.

Observability repairs stay typed. Each failure surface carries, for its
**purpose** and **reason**, the **common fixes**, a `docs_url`, and a
`repair_hint` so the next rerun stays local: the lane that failed, why it failed,
the concrete fixes to try, the doc to read, and the exact command to rerun.

## Budgets, quotas, and stops

Paid or unbounded work needs an explicit ceiling before it starts.

- State the budget in time, runner minutes, tokens, API calls, or dollars.
- State the quota or cap that will stop the run.
- State the kill switch or stop condition that aborts the work once the cap is
  hit. Every CI job declares a `timeout-minutes`; every proof lane declares a
  `timeout_seconds`.
- Capture evidence of the stop in the receipt so the next agent can tell a
  planned stop from a silent failure.
- Do not keep retrying a paid job after the cap is reached without a fresh
  approval receipt.

For this workspace:

- `just fast` writes a deterministic check + test snapshot for most edits.
- `just security` runs secret and dependency scanning before changes land.
- `just audit` writes the jankurai score under `.jankurai/` for repair routing.
- `just versions` prints the declared `VERSION`.
