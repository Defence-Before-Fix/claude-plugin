# Go

An instance of [the toolchain contract](CONTRACT.md). Grades are from `register.json`; re-read
it, since this page does not track it.

## Detection

`go.mod`, `go.work`, or tracked `*.go` files.

## Entry point

Whatever CI runs: commonly `make lint test`, `golangci-lint run ./...` followed by
`go test ./...`, a `Taskfile.yml` or `magefile.go` target, or `go vet ./...` alone.

## Rule host

| Host                                               | Register grade (detector) | Use it for                                                          |
| -------------------------------------------------- | ------------------------- | ------------------------------------------------------------------- |
| An existing go vet or Staticcheck check            | As its detector           | A class a bundled check already detects                             |
| An analyzer on `golang.org/x/tools/go/analysis`    | Amber, as go vet          | Any class over syntax and types; the native way to write a Go rule  |
| The same analyzer as a golangci-lint module plugin | Amber                     | Projects whose entry point is golangci-lint                         |
| Semgrep                                            | Amber                     | Pattern-shaped classes, and classes spanning Go and other languages |
| Staticcheck (bespoke rules)                        | Red                       | Nothing bespoke: a fixed catalogue. Keep running it as a check      |

**An analyzer** is a package exporting an `*analysis.Analyzer` with a `Name`, a `Doc` and a `Run`
function that calls `pass.Reportf` for each finding. Build it into a binary with
`golang.org/x/tools/go/analysis/singlechecker` (one analyzer) or `multichecker` (several), and
run it on its own. `go vet -vettool=<absolute path to the binary>` also runs it, but **replaces
the stock vet checks rather than adding to them**, so add the binary to the entry point as a step
beside `go vet ./...`, never in place of it. For golangci-lint,
register the same analyzer as a module plugin: `golangci-lint custom` builds a binary from
`.custom-gcl.yml`, and `.golangci.yml` enables it under `linters.settings.custom` with
`type: module`. Follow the installed golangci-lint version's plugin documentation, since the
configuration shape changed between major versions.

Skip generated files in `Run`: `ast.IsGenerated(file)` (Go 1.21 and later) recognises the
`// Code generated ... DO NOT EDIT.` header.

## Harness and proof

- The fixture test is `analysistest.Run(t, analysistest.TestData(), Analyzer, "<pkg>")`, over
  packages under `testdata/src/<pkg>/`, where each line that must fire carries a
  `// want "<regexp>"` comment and a line without one must stay silent. `go test` never compiles
  `testdata/`, so the fixtures stay out of the build, and `./...` does not match them, so they
  stay out of the sweep.
- One rule against one file: `<binary> ./path/to/file.go`, or
  `go vet -vettool=<binary> ./path/to/file.go`. A single file is analysed as a package of its
  own, so a file that depends on the rest of its package needs its package named instead.
- Exit codes differ: the checker alone exits 3 on a finding and `go vet` exits 2. Test for
  non-zero, not for a number.

## Identifier and page

**`go vet` and a checker binary print the message only, not the analyzer's name**, so start every
`pass.Reportf` message with the rule's identifier and end it with the page's path. golangci-lint
appends the linter's name in brackets, which is the identifier when the plugin is named after
the rule. A singlechecker binary prints the analyzer's `Doc` with `-h`, and a multichecker
binary prints it with `help <name>`; that resolves offline, so put the correct construction in
`Doc` or name the page there.

## Sweep

`<binary> ./...` from the module root, once per module in a `go.work` workspace. Test files are
analysed by default. Semgrep, if used instead, skips `*_test.go` by default, as the contract's
[Semgrep section](CONTRACT.md#semgrep-as-the-fallback) says. `./...` already leaves out
`vendor/` and `testdata/`; generated files need the `ast.IsGenerated` check above. Compare with
`git ls-files '*.go'`, allowing for those exclusions.

## Listing and project record

`golangci-lint linters` lists what the configuration enables; a checker binary lists
its analyzers with `help` (multichecker) or `-h`. Neither lists the other. Exclusions live in
`.golangci.yml` (`issues.exclude-rules` in version 1, `linters.exclusions.rules` in version 2);
YAML comments carry any justification, and nothing rejects a missing one.

## Suppression routes

| Route                                 | Tool          | What closes it                                                                        |
| ------------------------------------- | ------------- | ------------------------------------------------------------------------------------- |
| `//nolint`, `//nolint:<linter>`       | golangci-lint | A rule of the project's own; `nolintlint` can demand a reason, but allows the comment |
| `//lint:ignore`, `//lint:file-ignore` | Staticcheck   | A rule of the project's own                                                           |
| `// nosemgrep`                        | Semgrep       | `semgrep scan --disable-nosem`                                                        |

A rule of the project's own for comment forms is a Semgrep `pattern-regex` rule or an analyzer
that reads `file.Comments`.

## Runner

`go test ./...`, with the flags the project's entry point already passes (`-race`, `-count=1`,
build tags). The analyzer's `analysistest` test runs in the same suite.

## CI hook

`.github/workflows/`, `.gitlab-ci.yml`, `Makefile`, `.golangci.yml` and
`.pre-commit-config.yaml`. An analyzer registered as a module plugin runs only in the binary
`golangci-lint custom` builds. Record whether CI runs that binary or a stock golangci-lint, since
with a stock one CI does not run the rule; that is information for the owner, as the contract's
[CI hook](CONTRACT.md#ci-hook) section says.

## Known gaps

- The register grades go vet partial on detector clause 4.3 because it had not verified that
  the analyzer's name reaches plain output. Running it shows only the message is printed, so the
  identifier lives in the message by convention only.
- Staticcheck cannot host a bespoke rule.
