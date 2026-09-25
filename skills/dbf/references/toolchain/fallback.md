# No native tooling

An instance of [the toolchain contract](CONTRACT.md) for two situations: a language with no guide
beside this file (Ruby, Java, Kotlin, C#, Swift, C and C++, Terraform, Dockerfiles, YAML
configuration and the rest), and a project in a covered language that runs no detector able to
host a rule.

## Detection

Whatever `git ls-files` shows that no guide claims. Group the tracked files by extension, and by
shebang for files without one, and treat each group with more than a handful of first-party files
as a language the class may occur in.

## Entry point

Find it as the contract's [entry point](CONTRACT.md#entry-point) section says, and add a new
host's invocation to it the same way. If the project has no command that accepts changes at
all, there is nowhere to make the rule permanent: write the rule, prove it and sweep with it,
then refer the missing entry point to the owner and leave the rule unmerged, because creating
the project's checks from nothing is a toolchain decision and not yours. Do not claim method
clause [3.5](../spec/SPEC.md#35-enforce-permanently-and-block) is met.

## Rule host

The contract's [rule host](CONTRACT.md#rule-host) order applies unchanged. For a language with
no guide, it reads:

1. **An existing rule, or a tightening of existing configuration**, in a detector the project
   already runs, where it genuinely detects the class.
2. **A detector the project already runs** that can host a bespoke rule, even one the register
   does not grade, such as RuboCop, Checkstyle, PMD, detekt, a Roslyn analyzer, SwiftLint custom
   rules, clang-tidy or tflint. Report an ungraded one as ungraded, and a graded one with its
   grade: Checkov, for one, is graded red.
3. **A detector the register grades for the language** that can host a bespoke rule, preferring
   a green detector grade. Its register page is on the site; where the network is unavailable,
   the tool's own installed documentation is the source.
4. **Semgrep**, the universal fallback. `semgrep show supported-languages` lists the grammars the
   installed version parses; its `generic` mode and `pattern-regex` cover formats with no
   grammar. The contract's [Semgrep section](CONTRACT.md#semgrep-as-the-fallback) covers its
   identifier prefix, harness and silently skipped files. ast-grep is the alternative where the
   project uses it or Semgrep lacks the grammar.
5. **A check script**, meeting the contract's [check scripts](CONTRACT.md#check-scripts) section,
   written in a language the project already runs so that nobody installs a runtime for it.

Installing Semgrep or ast-grep into a project that has neither adds a dependency: say so in the
report, add it the way the project adds its other development tools, and keep it out of what the
project ships.

## Harness and proof

As the host provides: `semgrep scan --test <rules-dir>` with `ruleid:` and `ok:` fixture
comments, `ast-grep test` with its rule-test files, or the check script run on a fixture pair.

## Identifier and page

The message carries the identifier and the page's path, since none of the fallback hosts
resolves a project identifier offline on its own. Choose the identifier format and the page's
location as the contract's [identifier and page](CONTRACT.md#identifier-and-page) section says,
and record both as the project's decisions.

## Sweep

List the files explicitly from `git ls-files`, by extension and by shebang, and pass the list to
the tool, so nothing depends on how it walks directories. Exclude vendored, generated and build
output, and the fixtures.

## Listing and project record

A project with no toolchain has no listing and no record. List the rule files the entry point
loads, report both gaps against toolchain sections [5](../spec/TOOLING-SPEC.md#5-enumeration) and
[6](../spec/TOOLING-SPEC.md#6-the-project-record), and do not invent a record format for the
owner.

## Suppression routes

Every host has at least one: `nosemgrep`, `ast-grep-ignore`, and each native detector's own
comment. Where you add Semgrep, pass `--disable-nosem` from the start. For a detector the
project already runs, report its routes and whether the project forbids them, and leave closing
them to the owner, as the contract's
[suppression routes](CONTRACT.md#listing-project-record-and-suppression-routes) paragraph says.

## Runner

The project's test runner, for the check script's fixture test and the original defect's
reproducing test. A project with no runner cannot carry the reproducing test; report that
rather than adding a runner.

## CI hook

As the contract's [CI hook](CONTRACT.md#ci-hook) section says.

## Known gaps

Everything above that the project could not supply. On a project with no toolchain the report's
gap section is long, and that is the correct result: the gaps belong to the toolchain's owner.
