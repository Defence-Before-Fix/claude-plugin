# Defence Before Fix: Claude Code plugin

Defence Before Fix (DBF) is a phase that runs before a defect is fixed: the instance is treated
as evidence of a class, and the defence that detects the class is built and seen to fire before
the fix is made. Specification: https://defence-before-fix.github.io/

This plugin gives Claude Code one skill, `/dbf`, that runs the method in the project you are
working in, and two agents the skill dispatches: an independent searcher, whose fresh context
is what makes the method's independent search independent, and a conformance reviewer that
checks the finished remediation against the specification before the report issues.

## Install

```
/plugin marketplace add Defence-Before-Fix/claude-plugin
/plugin install defence-before-fix@defence-before-fix
```

Or from a shell:

```bash
claude plugin marketplace add Defence-Before-Fix/claude-plugin
claude plugin install defence-before-fix@defence-before-fix
```

To install for everyone on a project rather than for yourself, add `--scope project` to both
commands; that records the marketplace and the plugin in the project's `.claude/settings.json`.

## Use

Say `DBF` or `/dbf` when you have found a defect, or describe the defect and let the skill
trigger. The skill reads the specification, discovers the project's toolchain, and follows the
method: attribute the defect to a class, write and prove a detector rule, search independently,
sweep and count, fix every instance within its authority, make the rule permanent and
blocking, and only then fix the original defect. It ends with a report in a fixed shape.

The skill works in any language. It detects the languages a project is written in, polyglot
projects included, and reads a toolchain guide for each: Python, JavaScript and TypeScript, PHP,
Go, Rust and shell have one. Every guide is an instance of one language-neutral contract, which
names what each step needs (a rule host, a single-rule harness, an identifier that resolves, a
sweep, the project's entry point) and falls back to Semgrep where a language has no detector
that can host a bespoke rule. A language with no guide is handled from the contract and a
fallback guide.

The skill will not baseline, suppress or narrow a rule on its own authority, and will not
change the project's manifest declaration. Those decisions belong to whoever owns the codebase.

The skill pre-approves only reading files and running its own refresh script. Running the
toolchain, editing rules and committing go through your normal permission rules.

## Which specification it reads

The plugin vendors a snapshot of the method, detector and toolchain specifications, the
generated agent prompt and the tools register, pinned to the versions in `SPEC-VERSION`. On
each run the skill's refresh script fetches the canonical raw markdown from the site into the
plugin's data directory when the cached copy is older than a day, and falls back to the cached
or vendored copy when the network is unavailable. The report states which copy and version was
read.

The specification documents are published under CC BY 4.0 by Joseph Edmonds; the snapshot
carries its licence. The plugin's own files are MIT.

## Layout

| Path                                       | What it is                                                                                                   |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------------------ |
| `.claude-plugin/plugin.json`               | The plugin manifest                                                                                          |
| `.claude-plugin/marketplace.json`          | This repository as its own marketplace                                                                       |
| `skills/dbf/SKILL.md`                      | The skill: invocation, discovery, the method's order, the report                                             |
| `skills/dbf/references/REPORT-TEMPLATE.md` | The report shape every run fills in                                                                          |
| `skills/dbf/references/spec/`              | The vendored specification snapshot, with the register pages for the two reference toolchains under `tools/` |
| `skills/dbf/references/toolchain/`         | The language-neutral toolchain contract, one guide per language, and the fallback guide                      |
| `skills/dbf/scripts/refresh-spec.bash`     | The TTL refresh and copy resolver                                                                            |
| `agents/independent-searcher.md`           | The searcher that never sees the rule                                                                        |
| `agents/conformance-reviewer.md`           | The reviewer that checks the work against the specification                                                  |
| `SPEC-VERSION`                             | The pinned specification versions and source commit                                                          |
| `evals/`                                   | The `claude plugin eval` suite; see Evals below                                                              |

The `skills/dbf` folder is in the Agent Skills format, so it can also be copied into another
harness's skills directory without the plugin manifest.

## Evals

`evals/` holds a `claude plugin eval` suite. Each case runs with the plugin and without it, and
the difference is what the plugin contributes. `zero-discount-defect` gives a small TypeScript
project with a QA entry point (`bin/qa`) and a support ticket for a defect whose class, `||`
defaulting a numeric field where 0 is valid, occurs three times across two files. Its graders
are deterministic: a check was added under `qa/checks/` and seen failing through `bin/qa`
before any file in `src/` was edited, the reply states the instance count, every instance is
fixed, and nothing is suppressed. Whether the skill fired is reported as an indicator, not
scored.

The case seeds its workspace with a scaffold script and needs Bash, Write and Edit, so run it
with those granted. Bash runs under Claude Code's sandbox, which on Linux needs `bubblewrap`
and `socat`; the fixture needs Node 24 and `tsc` on the `PATH`.

```bash
claude plugin eval . --scaffold --model sonnet --concurrency 2 --no-publish \
  --max-cost-usd 15 --allow-tools Bash Write Edit
```

Every run is a paid model call. The `Evals` workflow runs the suite on demand and on pushes to
`main`, and skips itself when the repository has no `ANTHROPIC_API_KEY` secret.
