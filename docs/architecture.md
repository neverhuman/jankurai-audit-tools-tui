# jankurai-tools-tui Architecture

jankurai-tools-tui is the **tuiwright** workspace: a Playwright-style black-box
testing framework for terminal user interfaces, its CLI, and an example demo.

```text
Rust core + TypeScript/React/Vite product surface + PostgreSQL truth
+ generated contracts + exception-only Python AI/data service
```

This repository is the Rust arm of that family standard. New implementation is
Rust-first. There is no web surface, no PostgreSQL database, and no Python
AI/data service committed here, so those stack arms are not applicable. Agents
must not introduce Python for repo tooling, proof lanes, or product logic.

## Crates

| Crate | Role |
| --- | --- |
| `crates/tuiwright` | the library: spawn apps in a real PTY, parse output into a deterministic screen model, drive keyboard/mouse/paste/resize input, and provide locators, polling assertions, screenshots, GIF recordings, and JSONL traces |
| `crates/tuiwright-cli` | the `tuiwright` binary that wraps the library for screenshots, recordings, and traces |
| `examples/tuiwright-demo` | a small counter TUI used as the fixture the integration tests drive |

## Module layers

Within `crates/tuiwright/src` the layers separate pure logic from effects:

- **Pure model and encoding** — `screen.rs`, `locator.rs`, `input.rs`,
  `render.rs`. These parse terminal output and encode input deterministically
  with no ambient effects.
- **Effectful drivers** — `session/`, `session.rs`, `record.rs`, `config.rs`,
  `trace.rs`. These own the PTY, filesystem, and timing concerns.

The pure modules are the declared domain in
[`agent/boundaries.toml`](../agent/boundaries.toml).

## Routing

Agents should prefer [`agent/owner-map.json`](../agent/owner-map.json) and
[`agent/test-map.json`](../agent/test-map.json) for changes, then route to the
smallest proof lane in [`agent/proof-lanes.toml`](../agent/proof-lanes.toml).
