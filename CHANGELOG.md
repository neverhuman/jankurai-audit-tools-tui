# Changelog

All notable changes to jankurai-tools-tui are documented in this file. The
format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
The authoritative version string lives in [`VERSION`](VERSION).

## [Unreleased]

### Changed

- `tuiwright` and `tuiwright-cli` package versions are `1.7.1`, matching the public CLI release.

### Added

- Root `Justfile` command surface with `setup`, `fast`, `check`, `security`, and
  `audit` lanes for one-command setup and validation.
- GitHub Actions CI (`.github/workflows/ci.yml`) with build, security, jankurai
  audit, and tool-adoption jobs; all third-party actions pinned to commit SHAs.
- Pinned CI script entrypoints under `ops/ci/` (`fast.sh`, `security.sh`,
  `audit.sh`, `tool-adoption.sh`, `quality-gates.sh`, `required.sh`, `lib.sh`).
- Agent-readable documentation: `README.md`, `docs/architecture.md`,
  `docs/boundaries.md`, `docs/testing.md`, `docs/release.md`, and
  `docs/exceptions.md`, plus `ops/AGENTS.md`.
- Property tests for the input-encoding surface
  (`crates/tuiwright/tests/encoding_props.rs`) using `proptest`.

### Changed

- Re-scoped `agent/boundaries.toml`, `agent/owner-map.json`,
  `agent/test-map.json`, `agent/generated-zones.toml`, and
  `agent/proof-lanes.toml` to the paths that exist in this workspace, and added
  `agent/audit-policy.toml` excluding transient build trees.

## [0.1.0] - 2026-06-12

### Added

- Initial split-family extraction of the tuiwright TUI testing libraries, CLI,
  and example demo.
