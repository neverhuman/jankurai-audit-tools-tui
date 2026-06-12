# jankurai-tools-tui

[![ci](https://img.shields.io/github/actions/workflow/status/neverhuman/jankurai-tools-tui/ci.yml?branch=main&label=ci)](.github/workflows/ci.yml)

Playwright-style black-box testing for terminal user interfaces. This repository
is one member of the Jankurai split family; read [`SPLIT.md`](SPLIT.md) for the
family contract and [`AGENTS.md`](AGENTS.md) for agent routing rules.

## Stack

Rust core + TypeScript/React/Vite product surface + PostgreSQL truth + generated
contracts + exception-only Python AI/data service. This workspace is the Rust
arm of that standard; see [`docs/architecture.md`](docs/architecture.md).

## Quick start

```bash
# One-command setup (toolchain + locked dependencies).
just setup

# Deterministic fast lane (check + tests).
just fast

# Full local check: format, lint, fast, security, and self-audit.
just check
```

The full command surface lives in the root [`Justfile`](Justfile). Continuous
integration runs the same lanes under
[`.github/workflows/ci.yml`](.github/workflows/ci.yml) via the pinned scripts in
[`ops/ci/`](ops/ci).

## Layout

| Path | Role |
| --- | --- |
| `crates/tuiwright` | terminal testing library (screen model, locators, input, render, record) |
| `crates/tuiwright-cli` | `tuiwright` CLI: screenshots, recordings, traces |
| `examples/tuiwright-demo` | example TUI app exercised by the integration tests |
| `agent/` | machine-readable owner, test, boundary, and proof maps |
| `docs/` | architecture, testing, boundaries, release, and exception docs |
| `ops/` | pinned CI script entrypoints |
| `scripts/` | local CI runner |
| `schemas/` | JSON Schema contracts for emitted artifacts (trace events) |

## Documentation

- [Architecture](docs/architecture.md)
- [Testing](docs/testing.md)
- [Boundaries](docs/boundaries.md)
- [Release process](docs/release.md)
- [Agent exceptions and overrides](docs/exceptions.md)
- [Tuiwright user guide](docs/tuiwright.md)

## Versioning

The current version is recorded in [`VERSION`](VERSION) and the change history in
[`CHANGELOG.md`](CHANGELOG.md). Release mechanics are documented in
[`docs/release.md`](docs/release.md).

## License

See [`LICENSE`](LICENSE).
