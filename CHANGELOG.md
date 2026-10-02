# Changelog

## 0.3.0

Behaviour changes, from a second execution test of 0.2.1 on a real defect, run headless.

- **The rule's scope is settled against the specification, with an output.** In both
  execution tests the practitioner never opened `SPEC.md`, and the second failed at exactly the
  decision section 4 governs: the rule was narrower than the class the practitioner had named,
  and the widening was referred upwards although it was within its authority. Step 5 now requires
  reading clause 3.1, clause 3.3 Part B and section 4 and writing the report's new **Scope
  decision** section before the sweep: each part of the named class with whether the rule
  detects it, every search finding placed against the class, each in-class miss widened or left
  narrower by one of the recorded routes (an owner decision under section 4's last bullet, a
  suppression where no Part B sentence can be written, or a clause 3.2 toolchain gap), and the
  clause text each decision relies on quoted verbatim. The instances the search found are fixed
  regardless of the route. Step 7 requires each referral to quote the section 4 bullet it falls
  under, or clause 3.2 for a toolchain gap that cannot be recorded in the toolchain; a decision
  that fits none is the practitioner's to make. The conformance reviewer checks the quotations
  against the specification and treats an unwidened or relabelled in-class finding as a finding
  against clauses 3.1 and 3.3.
- **The independent search has a home.** The searcher writes to
  `.dbf/reports/<date>-<class>-search.md`, committed with the report, never to `/tmp`. The
  reviewer writes its review beside it, at `.dbf/reports/<date>-<class>-review.md`.
- **Review findings resolve by kind.** Section 7 rests a verdict on reproduction, not on the
  report. A finding about the work is resolved only by a commit that changes the work, followed
  by a fresh review. A finding about the report itself is resolved by revising the report, and
  the reviewer confirms the record findings without reproducing again. Committing the report,
  the search file and the review file does not call for another review. The report template
  gains a **Conformance review** section.
- **The cache goes to the plugin's data directory.** Claude Code does not export
  `CLAUDE_PLUGIN_DATA` to commands the skill runs, so the cache always fell back to `~/.cache`.
  The refresh script takes `--data-dir`, and the skill passes the substituted
  `${CLAUDE_PLUGIN_DATA}`; an empty value falls back as before.
- **Register pages are refreshed, not only vendored.** The refresh script fetches `register.json`
  and the php-qa-ci and ts-qa-ci register pages from the site's `/raw/tools/`, with the vendored
  copies as the offline fallback. The fallback guide gives the raw URL for any other tool's page.
- **Specification snapshot: method 1.1.0**, detector 1.0.0, toolchain 0.2.0, at
  `0c9f64fb29b1377ac67ab54fef78e13de1cf3b5d`.

## 0.2.1

- The independent searcher is dispatched in the foreground, and nothing is fixed until its
  result is reconciled.
- The conformance reviewer is dispatched again whenever resolving a finding changes the defence.
- The report defaults to `.dbf/reports/<date>-<class>.md`, and the final message opens with the
  specification version and source.
- The reviewer reproduces in a detached worktree of its own and leaves no branch behind.

## 0.2.0

- A language-neutral toolchain contract, with guides for Python, JavaScript and TypeScript, PHP,
  Go, Rust and shell, and a fallback guide for any other language.

## 0.1.1

- Review findings on 0.1.0 applied.

## 0.1.0

- The `/dbf` skill, the independent searcher and the conformance reviewer.
