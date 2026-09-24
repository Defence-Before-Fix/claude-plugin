# Defence Before Fix: Claude Code plugin

Defence Before Fix (DBF) is a phase that runs before a defect is fixed: the instance is treated
as evidence of a class, and the defence that detects the class is built and seen to fire before
the fix is made. The method is specified at <https://defence-before-fix.github.io/>.

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
| `skills/dbf/scripts/refresh-spec.bash`     | The TTL refresh and copy resolver                                                                            |
| `agents/independent-searcher.md`           | The searcher that never sees the rule                                                                        |
| `agents/conformance-reviewer.md`           | The reviewer that checks the work against the specification                                                  |
| `SPEC-VERSION`                             | The pinned specification versions and source commit                                                          |

The `skills/dbf` folder is in the Agent Skills format, so it can also be copied into another
harness's skills directory without the plugin manifest.
