# Boundaries

This repository is a single-purpose Rust workspace: the tuiwright TUI testing
library, its CLI, and an example demo. The machine-readable boundary manifest is
[`agent/boundaries.toml`](../agent/boundaries.toml); this document is its prose
companion.

## Domain

The product domain lives entirely under `crates/tuiwright/src`,
`crates/tuiwright-cli/src`, and `examples/tuiwright-demo/src`. There is no web
surface, no PostgreSQL database, and no Python AI/data service committed in this
repo, so those stack arms of the family standard are not applicable here.

## Forbidden imports in domain code

The pure model and encoding modules (`screen.rs`, `locator.rs`, `input.rs`)
parse output and encode input deterministically. They must not reach for ambient
effects. The forbidden import prefixes are declared in
[`agent/boundaries.toml`](../agent/boundaries.toml) and include `std::env`,
`std::net`, `std::time::SystemTime`, and any randomness, database, networking,
or logging crate. Effects belong in the session and record layers, not in the
pure core.

## Generated zones

Generated output is never hand-edited. The only generated zone in this repo is
`target/` (Cargo build output), declared in
[`agent/generated-zones.toml`](../agent/generated-zones.toml). It is regenerated
by the build, not committed.

## Ownership and proof

- [`agent/owner-map.json`](../agent/owner-map.json) assigns an owner to every
  top-level path that exists.
- [`agent/test-map.json`](../agent/test-map.json) routes each owned path to a
  deterministic proof command.
- [`agent/proof-lanes.toml`](../agent/proof-lanes.toml) defines the runnable
  lanes; every lane command executes in this repo alone.

## Reclassification

If a future change adds a web, database, or Python surface, update
`agent/boundaries.toml` first to declare the new boundary block, then add the
matching owner, test, and proof entries before landing the code.
