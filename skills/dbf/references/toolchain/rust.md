# Rust

An instance of [the toolchain contract](CONTRACT.md). Grades are from `register.json`; re-read
it, since this page does not track it.

## Detection

`Cargo.toml`, `Cargo.lock`, `rust-toolchain.toml`, or tracked `*.rs` files. A `Cargo.toml` with a
`[workspace]` table means several crates: `cargo clippy` and `cargo test` take `--workspace`,
and `cargo fmt` takes `--all`.

## Entry point

Whatever CI runs: commonly `cargo fmt --all --check`, then
`cargo clippy --workspace --all-targets -- -D warnings`, then `cargo test --workspace`, often
behind a `Makefile`, `justfile` or `cargo xtask` target, with `cargo deny check` alongside.

## Rule host

| Host                               | Register grade (detector) | Use it for                                                                 |
| ---------------------------------- | ------------------------- | -------------------------------------------------------------------------- |
| An existing Clippy lint            | Red, as Clippy            | A class a bundled lint already detects                                     |
| A Clippy ban list in `clippy.toml` | Red, as Clippy            | Banning a named method, function, type or macro                            |
| Semgrep                            | Amber                     | Pattern-shaped classes, the usual host for a project's own rule            |
| Dylint lint library                | Ungraded                  | Classes needing types or the compiler's analysis                           |
| Clippy and cargo-deny, bespoke     | Red                       | Nothing bespoke: fixed catalogues, new lints only by upstream contribution |

**An existing lint or a ban list** is a tightening of existing configuration, which method
clause [3.2](../spec/SPEC.md#32-build-the-net) accepts where it genuinely detects the class. It
is still routed through a detector that fails detector clause 4.1, so record that as a toolchain
gap, as the contract's [rule host](CONTRACT.md#rule-host) section says. `clippy.toml` takes
`disallowed-methods`, `disallowed-types` and `disallowed-macros`, each entry a `path` and a
`reason`, and Clippy prints the reason as a note beneath the finding. Every ban prints the one
bundled identifier, `clippy::disallowed_methods` or its sibling, so start the reason with the
project's own identifier and end it with the page's path. Make the lint blocking in `Cargo.toml`:

```toml
[lints.clippy]
disallowed_methods = "deny"
```

**Semgrep** is the host for a project's own rule when the class is a syntactic pattern that no
ban list expresses.

**Dylint** (`cargo dylint`) loads lint libraries the project writes against the compiler's lint
interface. Each library pins a nightly toolchain, and its `dylint_testing` crate runs fixture
files against expected-output files. It is not in the register; report it as ungraded and check
its harness and output yourself.

## Harness and proof

- Clippy: run the one lint alone over a fixture with
  `cargo clippy --all-targets -- -A warnings -A clippy::all -A clippy::restriction -D clippy::disallowed_methods`.
  Every ban in `clippy.toml` shares that lint, so the harness cannot separate one ban from the
  others; a fixture that calls only the banned path is the proof.
- Semgrep: `semgrep scan --no-rewrite-rule-ids --config <rule-file> --error <file>`, and
  `semgrep scan --test <rules-dir>` for its fixtures.
- Dylint: the library's UI tests, run by `cargo test` in the library's directory.

## Identifier and page

`cargo clippy --explain <lint>` prints a bundled lint's documentation offline; it knows nothing
of the project's reasons, which is why the reason names the page. Clippy's output links to its
online documentation as well. For Semgrep, the identifier is the rule's id, printed as written
with `--no-rewrite-rule-ids`.

## Sweep

`cargo clippy --workspace --all-targets --all-features` covers library, binary, test, example
and bench targets; a class that differs by feature needs each feature set the project builds.
Exclude `target/`, a `vendor/` directory from `cargo vendor`, and code generated into `OUT_DIR`
by build scripts. Compare with `git ls-files '*.rs'`. Semgrep skips `tests/` by default, as the
contract's [Semgrep section](CONTRACT.md#semgrep-as-the-fallback) says, which drops a crate's
integration tests from its sweep.

## Listing and project record

`clippy.toml` and the `[lints]` tables in `Cargo.toml` are the configuration the entry point
loads; neither tool prints a listing of project rules, so report the gap against toolchain
section [5](../spec/TOOLING-SPEC.md#5-enumeration) and list what the files declare. Those same
files are where a project-level exception would sit; a TOML comment is the justification, and
nothing rejects a missing one.

## Suppression routes

| Route                           | What closes it                                                                                      |
| ------------------------------- | --------------------------------------------------------------------------------------------------- |
| `#[allow(...)]` on an item      | `allow_attributes = "deny"` under `[lints.clippy]`; it steers to `#[expect]`, which is still inline |
| `#[expect(...)]` on an item     | A rule of the project's own                                                                         |
| `#![allow(...)]` at crate level | A rule of the project's own; `allow_attributes` does not fire on an inner attribute                 |
| `// nosemgrep`                  | `semgrep scan --disable-nosem`                                                                      |

`allow_attributes_without_reason` demands a `reason = "..."` on each attribute but still allows
it. A rule of the project's own for attribute forms is a Semgrep `pattern-regex` rule. Whether
to close a route on a tool the project already runs is the owner's decision, as the contract's
[suppression routes](CONTRACT.md#listing-project-record-and-suppression-routes) paragraph says.

## Runner

`cargo test --workspace`, or `cargo nextest run` where the project uses nextest. Doc tests run
only under `cargo test`.

## CI hook

`.github/workflows/`, `.gitlab-ci.yml`, `Makefile`, `justfile`, `xtask/` and `deny.toml`. Record
whether CI passes the same `-D warnings` or `[lints]` levels as the entry point, since a denied
lint may only warn there.

## Known gaps

- Neither Clippy nor cargo-deny can host a bespoke lint; a Clippy ban list is a tightening of a
  bundled lint, not a rule of the project's own, and it shares one identifier across every ban.
- Dylint, the one Rust host for a typed bespoke lint, is not graded in the register.
