# JavaScript and TypeScript

An instance of [the toolchain contract](CONTRACT.md). Grades are from `register.json`; re-read
it, since this page does not track it. The reference toolchain is ts-qa-ci, and its register
page, `tools/ts-qa-ci.md` at the path the refresh script prints (vendored at
[spec/tools/ts-qa-ci.md](../spec/tools/ts-qa-ci.md)), is the verified source for every ts-qa-ci
command below.

## Detection

`package.json`, `tsconfig.json`, a lock file (`package-lock.json`, `pnpm-lock.yaml`,
`yarn.lock`, `bun.lockb`), or tracked `*.ts`, `*.tsx`, `*.js`, `*.jsx`, `*.mjs` or `*.cjs` files.
ts-qa-ci is present when `package.json` depends on `@longtermsupport/ts-qa-ci` and a `tsQaConfig/`
directory exists. The manifest declaration, if the project made one, is `defenceBeforeFix` in
`package.json`, with its gaps under `knownGaps`.

## Entry point

With ts-qa-ci, `ts-qa`, run through the project's package manager, which runs its phases
fail-fast with detectors before tests, and takes `-p <path>` to narrow. Without it, whatever CI
runs: commonly a `package.json` script such as `lint` then `typecheck` then `test`. Prefer the
project's own script names over calling tools directly.

## Rule host

| Host                                  | Register grade (detector) | Use it for                                                                |
| ------------------------------------- | ------------------------- | ------------------------------------------------------------------------- |
| An existing ESLint rule               | Amber                     | A class a core or installed plugin rule already detects                   |
| An ESLint plugin rule                 | Amber                     | Any class over syntax; the host ts-qa-ci wraps                            |
| The same rule using typescript-eslint | Amber                     | Classes that need type information                                        |
| oxlint JS plugin                      | Amber                     | Projects that lint with oxlint rather than ESLint                         |
| dependency-cruiser rule               | Amber                     | Import-graph and layering classes                                         |
| Semgrep                               | Amber                     | Pattern-shaped classes, and classes spanning JS or TS and other languages |
| tsc, Biome, Prettier                  | Red                       | Nothing bespoke; keep running them as checks                              |

An ESLint rule is an object with `meta` and `create`, placed in a local plugin object in the flat
configuration (`plugins: { <prefix>: { rules: { <name>: rule } } }`) and enabled as
`"<prefix>/<name>": "error"`. With ts-qa-ci, that configuration is `tsQaConfig/eslint.config.js`,
which the toolchain merges into its own.

## Harness and proof

- ts-qa-ci: `ts-qa rule <identifier> <path>` runs the lint lane on the path and reports whether
  that one rule fired. It sees ESLint rules only: for a dependency-cruiser identifier it answers
  "did not fire" with exit 0, which is not a proof. Prove a dependency-cruiser rule by running
  dependency-cruiser itself over a fixture, and report the gap the register page records.
- Bare ESLint: `RuleTester` from `eslint` (or `RuleTester` from `@typescript-eslint/rule-tester`
  for typed rules), run by the project's test runner, with `valid` and `invalid` cases as the
  fixture pair.
- Keep fixtures outside the globs the ESLint configuration lints, or ignore them there.

## Identifier and page

ESLint prints `<prefix>/<name>` with every finding. ts-qa-ci's `ts-qa rule-doc <identifier>`
resolves it offline to a section of the project's own documentation. Bare ESLint resolves a
rule through `meta.docs.url`, which is a link rather than an offline lookup, so the message
names the project's page.

## Sweep

ts-qa-ci: the lint lane over the whole project, or `ts-qa rule <identifier> <dir>`. Bare ESLint:
the project's lint script over every first-party path, with only the new rule's findings counted.
Exclude `node_modules/`, `dist/`, `build/`, `coverage/`, generated clients and type
declarations, and the rule's fixtures. Check the file count against
`git ls-files '*.ts' '*.tsx' '*.js' '*.jsx' '*.mjs' '*.cjs'`.

## Listing and project record

ts-qa-ci: `ts-qa rules` lists every active defence from the resolved configuration, with the
project record beneath it; run it first on any project you arrive at. Its record is
`tsQaConfig/tier-a-exemptions.json`, and the toolchain rejects an entry without a specific
justification. Bare ESLint: `eslint --print-config <file>` shows the resolved rules for one file,
which is derived but not a listing; report the gap against toolchain section
[5](../spec/TOOLING-SPEC.md#5-enumeration).

## Suppression routes

| Route                                                               | Tool    | What closes it                                                                |
| ------------------------------------------------------------------- | ------- | ----------------------------------------------------------------------------- |
| `eslint-disable`, `eslint-disable-next-line`, `eslint-disable-line` | ESLint  | `linterOptions.noInlineConfig: true`, or ts-qa-ci's `ts-qa/no-eslint-disable` |
| `eslint-suppressions.json` bulk suppressions                        | ESLint  | A check of the project's own that fails on the file's presence                |
| `@ts-ignore`, `@ts-expect-error`, `@ts-nocheck`                     | tsc     | typescript-eslint's `ban-ts-comment`, or ts-qa-ci's `ts-qa/no-eslint-disable` |
| `oxlint-disable` forms                                              | oxlint  | ts-qa-ci's `ts-qa/no-eslint-disable`; otherwise a rule of the project's own   |
| `// nosemgrep`                                                      | Semgrep | `semgrep scan --disable-nosem`                                                |

Whether to close a route on a tool the project already runs is the owner's decision, as the
contract's [suppression routes](CONTRACT.md#listing-project-record-and-suppression-routes)
paragraph says.

## Runner

Vitest, Jest, Mocha or `node --test`, whichever the project uses; ts-qa-ci runs Vitest and
Playwright last.

## CI hook

`.github/workflows/`, `.gitlab-ci.yml`, the `package.json` scripts CI calls, and `husky` or
`lefthook` configuration for git hooks.

## Known gaps

The register page lists ts-qa-ci's recorded gaps: the dependency-cruiser lane sits outside its
harness, resolver and listing, the bulk suppressions file is not forbidden, and one core rule
resolves to a URL. Report any that bear on the rule you wrote.
