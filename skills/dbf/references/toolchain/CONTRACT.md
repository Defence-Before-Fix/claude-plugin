# The toolchain contract

The [toolchain specification](../spec/TOOLING-SPEC.md) and the
[detector specification](../spec/DETECTOR-SPEC.md) say what a project's tooling must offer. They
are normative, vendored verbatim and refreshed from the canonical site, so this plugin does not
edit them. This file is the plugin's language-neutral reading of them: the slots every
remediation fills, in any language, and what each slot must do.

Each guide beside this file is an instance of the contract: it fills the same slots with the
commands for one language or one reference toolchain. Where the project's language has no guide,
fill the slots from this file alone, using [the fallback guide](fallback.md). A guide never
overrides the specification; where they differ, the specification governs and the guide has a
defect worth reporting.

## The slots

| Slot                  | What it must do                                                                                             | Governing clauses                                                                                                                                                                                                                                                                                                                                                                                                      |
| --------------------- | ----------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Entry point           | The one command the project runs to accept changes, running detectors before runners                        | Method [3.5](../spec/SPEC.md#35-enforce-permanently-and-block), toolchain [4.4](../spec/TOOLING-SPEC.md#44-the-toolchains-own-invocation-must-satisfy-the-detector-specifications-reporting-clauses-for-every-defence-it-routes) and [4.5](../spec/TOOLING-SPEC.md#45-the-toolchains-entry-point-must-run-detectors-before-runners-and-must-stop-on-a-detector-failure)                                                |
| Rule host             | A detector that reads code and in which the rule is written, bespoke wherever the class needs it            | Method [3.2](../spec/SPEC.md#32-build-the-net), detector [4.1](../spec/DETECTOR-SPEC.md#41-the-detector-must-support-bespoke-rules-written-by-the-project-that-runs-it), toolchain [4.1](../spec/TOOLING-SPEC.md#41-every-detector-the-toolchain-routes-a-defence-through-must-conform-to-the-detector-specification)                                                                                                  |
| Harness               | Runs one rule, on its own, against a file you name                                                          | Detector [4.2](../spec/DETECTOR-SPEC.md#42-the-detector-must-provide-a-harness-that-runs-a-single-rule-against-supplied-code)                                                                                                                                                                                                                                                                                          |
| Identifier and page   | A stable identifier printed with every finding, resolving offline to a page giving the correct construction | Method [3.6](../spec/SPEC.md#36-make-the-failure-message-terse-and-point-it-at-real-documentation), detector [4.3](../spec/DETECTOR-SPEC.md#43-the-detector-must-allow-a-rule-to-carry-a-stable-identifier-and-must-print-it-with-every-finding), toolchain [4.2](../spec/TOOLING-SPEC.md#42-the-toolchain-must-resolve-every-identifier-a-defence-it-routes-can-print-from-the-installed-copy-without-network-access) |
| Proof, red then green | The rule seen to fire and committed red on its own, then the entry point seen green with the rule loaded    | Method [3.3](../spec/SPEC.md#33-prove-the-net-by-making-the-rule-fire) and [3.5](../spec/SPEC.md#35-enforce-permanently-and-block)                                                                                                                                                                                                                                                                                     |
| Sweep                 | The one rule run over the whole first-party scope, with the scope and the count recorded                    | Method [3.4](../spec/SPEC.md#34-sweep-the-codebase-then-fix-every-instance)                                                                                                                                                                                                                                                                                                                                            |
| Listing               | Every active defence enumerated, with its identifier, without triggering it                                 | Method [8.5](../spec/SPEC.md#85-a-projects-defences-must-be-enumerable), toolchain [5](../spec/TOOLING-SPEC.md#5-enumeration)                                                                                                                                                                                                                                                                                          |
| Project record        | A file the toolchain reads, holding each exception with a justification naming hazard and scope             | Method [8.7](../spec/SPEC.md#87-recorded-project-decisions-must-be-discoverable-by-the-same-means), toolchain [6](../spec/TOOLING-SPEC.md#6-the-project-record)                                                                                                                                                                                                                                                        |
| Suppression routes    | Every inline ignore that bypasses the record, forbidden or failed by a defence                              | Detector [7](../spec/DETECTOR-SPEC.md#7-suppression), toolchain [4.3](../spec/TOOLING-SPEC.md#43-the-toolchain-must-forbid-through-a-defence-of-its-own-every-suppression-route-that-bypasses-the-project-record)                                                                                                                                                                                                      |
| Runner                | The test runner that carries the fixture test and the original defect's reproducing test                    | Method [3.3](../spec/SPEC.md#33-prove-the-net-by-making-the-rule-fire) and [5](../spec/SPEC.md#5-ordering-the-quality-checks)                                                                                                                                                                                                                                                                                          |
| CI hook               | Where the entry point runs on every change; read and recorded as information, never edited                  | None: method [3.5](../spec/SPEC.md#35-enforce-permanently-and-block) and section [8](../spec/SPEC.md#8-operating-a-defence-under-ai-assisted-development) place CI out of scope                                                                                                                                                                                                                                        |

A slot the project cannot fill, other than the CI hook, is a gap. Report it under the clause
named, as the method's clause [3.2](../spec/SPEC.md#32-build-the-net) says; do not build a
toolchain mechanism on your own authority to hide it. A project with no CI has no gap: the
specification does not ask for one.

## Entry point

Find the command the project runs to accept changes before anything else, because the green run
must go through it. Look, in this order, at what CI runs, at the task runner (a `Makefile`,
`justfile`, `Taskfile.yml`, `package.json` scripts, `tox.ini`, `noxfile.py`, an `xtask`), at a
`.pre-commit-config.yaml`, and at a `scripts/` or `bin/` directory of QA scripts. Record the
command you settled on and why. If the project has several, the one CI runs is the one that
accepts changes.

The rule must be in the checks that entry point runs, or it is not permanent. Where the host
you chose is one the entry point already runs, add the rule to the configuration it loads.
Where it is not, because the host is new to the project, add the host's invocation to the entry
point itself, the task-runner target or QA script it runs, beside the other detectors and before
the runner, and say in the report that the project gained a detector. Never replace an existing
check with the new one.

Where the only definition of the checks is the CI configuration itself, there is no entry point
this skill will edit. The specification places CI out of its scope rather than forbidding
changes to it; leaving CI alone is this plugin's own policy, because CI is the owner's
business. Prove and sweep the rule, leave it unmerged, and refer the wiring to the owner with
the exact step to add.

## Rule host

Choose where the rule lives in this order, stopping at the first that detects the class:

1. **An existing rule, or a tightening of existing configuration**, that genuinely detects the
   class, which method clause [3.2](../spec/SPEC.md#32-build-the-net) accepts. Where it lives in
   a detector that cannot host bespoke rules, such as a fixed catalogue with a configurable ban
   list, the detector still fails detector clause 4.1 and the toolchain fails its clause 4.1 for
   routing a defence through it: use it, and record that gap. It is only a conforming defence
   if method clause [3.6](../spec/SPEC.md#36-make-the-failure-message-terse-and-point-it-at-real-documentation)
   holds too: its message must lead, offline, to documentation stating the correct construction.
   A ban list whose message the project writes can name the project's page, and must, since
   every ban shares one bundled identifier. A bundled rule whose documentation is online only,
   and whose message the project cannot change, fails 3.6; prefer a later host that can carry
   the project's message, and use the bundled rule only where nothing later can express the
   class, recording the gap.
2. **The project's own rule host.** Run the listing first; if the project already writes
   bespoke rules somewhere, write this one there too.
3. **A native detector that can host a bespoke rule**, preferring one graded green for detector
   conformance in `register.json`. The language guide names the candidates.
4. **The universal fallback: Semgrep.** Local YAML rules, a test harness
   (`semgrep scan --test`), and support for most languages, shell and configuration formats
   included. ast-grep is an equal choice where the project already has it: the register grades
   it green, where Semgrep is amber.
5. **A check script**: a small program, in a language the project already runs, that parses the
   source (an abstract syntax tree where the language offers one, lines otherwise) and reports
   findings. The method's clause 3.2 makes a bespoke detector the last resort, and every clause
   of the method applies to it unchanged: see [check scripts](#check-scripts).

A formatter or a type checker cannot host a bespoke rule, and toolchain clause
[4.1](../spec/TOOLING-SPEC.md#41-every-detector-the-toolchain-routes-a-defence-through-must-conform-to-the-detector-specification)
point 3 keeps it as a check rather than a host. Keep running it.

### Semgrep as the fallback

- Rules are YAML files in one directory the project owns. Run offline:
  `semgrep scan --metrics=off --disable-version-check --no-rewrite-rule-ids --config <rules-dir> --error <paths>`.
  `--error` makes a finding fail the command. A `--config` value beginning `r/` or `p/` is read
  as a registry name, not a path: with a rules directory named `r`, Semgrep loads no rules and
  exits 0, a silent false pass. Write the path as `./r/...`, or choose another name.
- **Pass `--no-rewrite-rule-ids` everywhere.** Without it the printed identifier carries a
  prefix derived from the rule file's path relative to where the command ran
  (`qarules.no-bare-except`, not `no-bare-except`), so the harness and the entry point can print
  different identifiers for the same rule; the register fails Semgrep on detector clause 4.3 for
  this default. Starting the `message` with the identifier as well costs nothing.
- **The harness** is `semgrep scan --test <rules-dir>`: a fixture beside each rule file, with the
  same base name, marks each line that must fire with a `ruleid: <id>` comment and each line that
  must stay silent with an `ok: <id>` comment. Running one rule against one file is
  `semgrep scan --no-rewrite-rule-ids --config <rule-file> --error <file>`.
- **It skips files without saying so in the findings.**
  - With no `.semgrepignore` in the project, a default ignore list applies that skips `test/`
    and `tests/` directories, `*_test.go` files, `vendor/`, `build/` and `node_modules/`, even
    when you name the directory; a file named directly is scanned wherever it is. Where the
    class can occur in tests, pass the files explicitly, built from `git ls-files`. A
    `.semgrepignore` (an empty one replaces the defaults) is the other route, but only where the
    project does not run Semgrep yet: in a project that does, it widens every existing rule's
    scope and can turn the checks red on rules you did not write.
  - Files git ignores are skipped. Untracked files are scanned.
  - A file with no extension is scanned only when it is executable and has a shebang Semgrep
    recognises. `--scan-unknown-extensions` brings in other extensionless files, but only those
    named on the command line.
  - The run summary counts the files it scanned and the ones an ignore file skipped; compare the
    scanned count with the scope you meant.
- **Its inline route** is a `nosemgrep` comment, and `--disable-nosem` closes it.

### Check scripts

A check script is acceptable only when nothing above can express the class, and only when it
offers everything a detector must:

- It takes paths as arguments, so it runs over one file or the whole scope (detector
  [5.2](../spec/DETECTOR-SPEC.md#52-the-detector-must-support-invocation-over-a-subset-at-minimum-a-single-file)).
- It can run one rule by identifier, when it carries more than one (detector
  [4.2](../spec/DETECTOR-SPEC.md#42-the-detector-must-provide-a-harness-that-runs-a-single-rule-against-supplied-code)).
- It prints `path:line: IDENTIFIER message` for every finding and exits non-zero when there is
  one (detector [4.3](../spec/DETECTOR-SPEC.md#43-the-detector-must-allow-a-rule-to-carry-a-stable-identifier-and-must-print-it-with-every-finding)
  and [5.3](../spec/DETECTOR-SPEC.md#53-the-result-must-reach-the-practitioner-in-the-output-of-the-command-they-ran)).
  A file it cannot parse is an error with a different exit code, never a clean pass.
- It can list its rules without running them, which is the listing for the rules it hosts.
- It has no inline ignore of its own. Where the project has a record, exceptions are read from
  there; where it has none, the script has no exception mechanism at all, because designing one
  is the owner's decision.
- It has a test in the project's runner that runs it on a fixture that must fire and one that
  must stay silent.

## Identifier and page

Use the identifier format the project already uses; the listing shows it. Where it has none,
choose a prefix and a number or a slug, and record the choice as the project's decision.

The page goes where the project keeps rule documentation. Where it keeps none, propose a path
keyed on the identifier exactly as printed, such as `docs/rules/<IDENTIFIER>.md`, and put that
path in the rule's message, so the identifier resolves by reading a file named in the output
(method [8.3](../spec/SPEC.md#83-the-identifier-must-resolve-without-a-human)). The page states
what the rule is about, why it exists and how to fix a violation correctly
(method [3.6](../spec/SPEC.md#36-make-the-failure-message-terse-and-point-it-at-real-documentation)
and [8.4](../spec/SPEC.md#84-documentation-must-state-the-correct-construction-not-only-the-prohibition)).
Where the toolchain has a resolver command, check the new identifier resolves through it.

## Proof, red then green

1. Run the harness on the originating instance, or on a fixture where the pattern is not in the
   codebase. It must report the rule's identifier and exit non-zero. Keep the command and its
   output for the report. A harness that answers "did not fire" for an identifier it cannot see
   is not a proof; check the harness knows the rule, as the guides warn where one does not.
2. Keep a fixture pair as the rule's test: one file that must fire and one that must stay
   silent, in the host's own test form or in the project's runner. Keep fixtures where the sweep
   will not count them.
3. Commit the rule, its page and its fixtures as a commit of their own, before any instance is
   fixed. Where the originating instance is still in the codebase, the entry point fails on the
   rule at that commit; where the proof was on a fixture, the rule firing on that fixture is the
   red record.
4. After the fixes, run the entry point, over everything it covers, and see it green. A green
   run proves nothing unless the rule was loaded, so confirm it: the rule appears in the listing,
   the tool's count of loaded rules includes it, or its fixture fires in the same run. Running
   the detector directly proves the rule, not the defence.

## Sweep

Run the one rule, through the harness or the host's single-rule option, over every first-party
path in every language the pattern can occur in, not only the component the defect was reported
in. Exclude generated code, vendored dependencies, build output and the rule's own fixtures.
Record that scope, as the project's decision where it had none, and report the count.

Check the tool scanned what you meant: print the file count, or list the files, and compare it
with a count taken independently by `git ls-files` or `find`. A sweep that silently skips files
under-counts in the dangerous direction.

## Listing, project record and suppression routes

- **Listing.** Use the toolchain's listing where it has one, and check the new rule appears in it
  without further edits. Where it has none, the project lacks toolchain section
  [5](../spec/TOOLING-SPEC.md#5-enumeration); say so, and list what you can derive from the
  configuration the entry point loads.
- **Project record.** Read it before deciding anything, and never write to it on your own
  authority: an exception is the owner's decision under method section
  [4](../spec/SPEC.md#4-authority-which-decisions-belong-to-whom).
- **Suppression routes.** Each guide lists its detectors' inline ignore forms and the mechanism
  that closes each. For a host you are adding to the project, configure it with its routes
  closed from the start. For a host the project already runs, closing a route can surface
  findings someone chose to hide, and removing a suppression is the owner's decision: report the
  route and the mechanism, and change nothing.

## Runner

The runner carries the fixture tests of any rule hosted in a check script, and the test that
reproduces the original defect. The entry point runs it after the detectors. Use the project's
runner; do not introduce a second one.

## CI hook

Read the CI configuration (`.github/workflows/`, `.gitlab-ci.yml`, `.circleci/`,
`azure-pipelines.yml`, `Jenkinsfile`, `bitbucket-pipelines.yml`) and any git hook configuration,
and record whether they run the entry point you used. This is information for the owner, not a
finding against the project: the method's section
[8](../spec/SPEC.md#8-operating-a-defence-under-ai-assisted-development) places CI, git hooks
and branch policy out of scope, and the defence is demonstrated through the entry point either
way. Do not edit any of them: that is this plugin's policy, since what is out of the method's
scope is the owner's business.

## Writing a guide for another language

A guide is an instance of this contract. Give it these headings, in this order, and fill each
with commands you have run, not commands you expect to work: **Detection**, **Entry point**,
**Rule host**, **Harness and proof**, **Identifier and page**, **Sweep**,
**Listing and project record**, **Suppression routes**, **Runner**, **CI hook** and
**Known gaps**. Cite the register's grade for every detector it names, and name the ones the
register does not grade as ungraded.
