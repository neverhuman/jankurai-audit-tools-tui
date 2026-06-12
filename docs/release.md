# Release process

This document is the release control surface for jankurai-tools-tui. It covers
the version source, the changelog, the release automation, integrity and SBOM
evidence, and rollback. Launch gates require every section below to be backed by
a real artifact or command.

## Version source

The single source of truth for the version is the [`VERSION`](../VERSION) file at
the repository root. The crate versions in `crates/tuiwright/Cargo.toml`,
`crates/tuiwright-cli/Cargo.toml`, and any release tag MUST match `VERSION`. Tags
follow the family pattern `jankurai-tools-tui-v<MAJOR.MINOR.PATCH>-split.<N>` as
described in [`SPLIT.md`](../SPLIT.md).

## Changelog

Every release records its user-visible changes in
[`CHANGELOG.md`](../CHANGELOG.md) under a heading that matches the new `VERSION`.
The `Unreleased` section is promoted to a dated version heading at tag time.

## Release automation

Releases are cut by CI, not by hand:

1. Bump [`VERSION`](../VERSION) and promote the `Unreleased` section of
   [`CHANGELOG.md`](../CHANGELOG.md).
2. Run the full local gate: `just check` (format, lint, fast lane, security,
   self-audit).
3. Push the version commit. The
   [`ci.yml`](../.github/workflows/ci.yml) workflow runs the build, security,
   jankurai audit, and tool-adoption jobs and uploads the `repo-score` and
   `tool-adoption-evidence` artifacts.
4. Tag the release commit with `jankurai-tools-tui-v<version>-split.<N>`. The tag
   mirror in [`.jeryu/repo.toml`](../.jeryu/repo.toml) publishes the immutable
   tag to the public GitHub mirror.

Release builds depend on immutable tags, never branches.

## Integrity, provenance, and SBOM

- **Dependency integrity**: builds are reproducible because `Cargo.lock` is
  committed and every CI lane uses `--locked`.
- **SBOM**: generate a CycloneDX software bill of materials from the locked
  dependency graph with `cargo cyclonedx --format json` (run in CI alongside the
  security job) and attach it to the release as `sbom.json`.
- **Provenance**: the security job runs `gitleaks detect` for secret scanning and
  `cargo audit` for advisory checks; the audit job publishes the signed
  `repo-score` artifacts that prove the release passed the jankurai gate.
- **Action pinning**: every third-party GitHub Action is pinned to a 40-character
  commit SHA so the supply chain of the release pipeline itself is fixed.

## Launch gate

A release does not ship until the launch gate is green. The launch gate proves,
with artifacts, that the operational controls are in place:

- **Security**: `gitleaks` secret scanning and `cargo audit` dependency review
  pass in the security job; no committed secrets and no open advisories.
- **Backups**: this is a stateless Rust library workspace with no database, so
  the durable state to back up is the Git history and the immutable release tags
  on the public mirror; both are preserved by Jeryu and never force-pushed.
- **Monitoring**: CI uploads the `repo-score` and `tool-adoption-evidence`
  artifacts on every run so a regression in score or tool adoption is visible
  before a tag is cut.
- **Rollback**: see the section below; every release is reproducible from its
  immutable tag and committed `Cargo.lock`.
- **Abuse controls / rate limit**: the CLI and library perform no network calls
  and spawn only the application under test, so there is no external rate limit
  or abuse surface to budget; CI jobs are bounded by `timeout-minutes`.

## Rollback

If a release regresses:

1. Identify the last known-good tag
   (`jankurai-tools-tui-v<version>-split.<N>`).
2. Re-point consumers at that immutable tag; tags are never moved or deleted.
3. Open a revert commit that restores the previous `VERSION` and `CHANGELOG.md`
   state, and add a `### Fixed` entry describing the rollback.
4. Re-run `just check` to confirm the rolled-back tree is green before
   re-publishing.

Because tags are immutable and `Cargo.lock` is committed, any prior release can
be rebuilt bit-for-bit from its tag.
