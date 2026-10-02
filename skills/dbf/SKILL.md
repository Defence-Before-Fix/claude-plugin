---
name: dbf
description: Run the Defence Before Fix (DBF) method on a defect. Use whenever the user says "DBF", "Defence Before Fix", "defence before fix this", or asks you to fix a bug, a defect, a failing check or a red QA run in a project; and whenever a QA tool prints "Defence Before Fix" in its failure output. Before fixing anything, this skill attributes the defect to a class, writes and proves a detector rule for the class, sweeps and fixes every instance, and only then fixes the original defect.
argument-hint: "[description of the defect, or a file:line, or blank to work from the current failure]"
allowed-tools: Bash(bash ${CLAUDE_SKILL_DIR}/scripts/refresh-spec.bash *), Read, Grep, Glob
---

# Defence Before Fix

The method specification is the contract; this file is the runbook that applies it. Every step
below names the document and section that governs it. Do not paraphrase the method from
memory: read the copy the refresh script gives you.

The defect under remediation: $ARGUMENTS (if blank, work from the failure in front of you).

Everything beyond reading files and running the refresh script, such as running the
toolchain, editing rules and committing, goes through your normal permission rules; this skill
pre-approves nothing else.

## 0. Load the specification

Run the refresh script and read the project prompt it names:

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/refresh-spec.bash" --data-dir "${CLAUDE_PLUGIN_DATA}"
```

Run it as written: the harness substitutes both paths into this text, and the shell it runs in
does not carry them. In a harness that does not expand those variables, the script is at
`scripts/refresh-spec.bash` relative to this file, and an empty `--data-dir` makes it cache under
`~/.cache/defence-before-fix/spec`. It prints one line per document with the source (vendored,
cached or fetched), the version and the path; the paths it prints are the copies to read, here
and at every later step. Read `project-prompt.md` in full now; it is the method in the form an
agent follows, generated from the specification's Appendix A. `SPEC.md` is not optional
reading: step 5 below cannot be completed without it open, because its output quotes it. Read
section 3 whenever a step below is unclear. State the version and source in the report.

The refresh script never fails on a network error. If it reports a failed fetch, carry on with
the copy it listed.

## 1. Discover the project's toolchain

Do this before writing anything, so you know what is already defended.

- Read `references/toolchain/CONTRACT.md` beside this file. It is the language-neutral contract
  every remediation fills: the entry point, the rule host (with Semgrep as the universal
  fallback), the harness, the identifier and its page, the red and green proof, the sweep, the
  listing, the project record, the suppression routes, the runner and the CI hook, each tied to
  the clauses that govern it.

- Detect the project's languages from its tracked first-party files, with Glob or
  `git ls-files`, and pick the guide for each from the table below. A project is often several
  languages at once: take every guide whose language has first-party source, since the sweep
  must cover every language the class can occur in. Marker files say a toolchain is installed;
  source files say a language is written, so a manifest that only installs a formatter does not
  add a language to the sweep, though its tools may still be part of the entry point.

  | Language                  | Markers and source files                                                            | Guide                                |
  | ------------------------- | ----------------------------------------------------------------------------------- | ------------------------------------ |
  | Python                    | `pyproject.toml`, `setup.py`, `setup.cfg`, `requirements*.txt`, `*.py`              | `references/toolchain/python.md`     |
  | JavaScript and TypeScript | `package.json`, `tsconfig.json`, `*.ts`, `*.tsx`, `*.js`, `*.jsx`, `*.mjs`, `*.cjs` | `references/toolchain/typescript.md` |
  | PHP                       | `composer.json`, `*.php`                                                            | `references/toolchain/php.md`        |
  | Go                        | `go.mod`, `go.work`, `*.go`                                                         | `references/toolchain/go.md`         |
  | Rust                      | `Cargo.toml`, `*.rs`                                                                | `references/toolchain/rust.md`       |
  | Shell                     | `*.sh`, `*.bash`, `*.bats`, `*.zsh`, and extensionless files with a shell shebang   | `references/toolchain/shell.md`      |
  | Anything else             | Whatever the tracked files show that no row above claims                            | `references/toolchain/fallback.md`   |

  Where a language has no guide, fill the contract's slots from the contract and the fallback
  guide. Say in the report which guides you used and which languages had none.

- Read the manifest declaration, if the project made one, in whatever file its ecosystem records
  dependencies in. The toolchain specification's clause 9.2 fixes no key; a guide names the form
  its reference toolchain uses, where there is one. Report whatever form you find, including its
  known-gap record. Never add or change the declaration.

- Identify the toolchain. `register.json` from the refresh script is the graded index of tools
  by language, with a page link per tool; it does not carry commands. The guides carry commands,
  and cite the register's grades; for a tool no guide covers, the installed tool's own
  documentation is the source.

- Run the listing first. The specification's clause 8.5 requires defences to be enumerable
  without triggering them, and the listing tells you whether the class is already defended and
  what the project has recorded as exceptions. Where the project has recorded nothing, note the
  calibration you assume, because the report must say so. Where it has no listing, that is a
  gap to report, and the guide says what you can derive instead.

- Choose where the rule lives in the contract's rule-host order: an existing rule or
  configuration that already detects the class, then the project's own rule host, then a
  detector the register grades for the language, then Semgrep, then a check script. Say in the
  report what the project's tooling lacks.

## 2. Follow the method

The project prompt gives the order and the rules. In outline:

1. **Attribute** the instance to a class and name the hazard, in one sentence you can hand to
   someone else. If no class can be written as a rule, say so and fall back to the conventional
   fix the prompt allows.

2. **Dispatch the independent searcher now**, before any rule exists, so that its search would
   exist unchanged had the rule never been written. Dispatch
   `defence-before-fix:independent-searcher` with the class and hazard sentence, the paths of
   the detector's rule and configuration directories to keep out of, and the file to write to:
   `.dbf/reports/<date>-<class>-search.md` at the project root, named as the report is in
   section 3 below, or beside the report where the project keeps such records. Never a path
   outside the project such as `/tmp`: the search is evidence the report cites, and it is
   committed with the report. Dispatch it in the foreground, so that its result is in hand
   before you write the rule; a background dispatch lets the remediation run ahead of its own
   search. Fix nothing, the original included, until you have reconciled with it at step 5.

3. **Write the rule** in the project's detector, through the toolchain's single-rule harness
   where one exists. Draw it wider than the one instance and no wider than the hazard. Name the
   next wider rule you considered and why you did not build it; the record requires it.

4. **Prove the rule fires** on the originating instance or on a fixture you keep as its test,
   and commit the defence red, as a commit of its own, before any instance is fixed. The
   contract's proof section and the guide's harness say how, for the host you chose.

5. **Reconcile with the search, and settle the rule's scope.** The rule's scope is not accepted
   until this step's output exists. Open `SPEC.md` at the path the refresh script printed and
   read clause 3.1 from "Resolve the lower bound by searching independently" to the end of the
   clause, clause 3.3 Part B, and section 4. Then write the report's **Scope decision** section,
   before step 6:

   - the class sentence from step 1, unchanged;
   - each part of that sentence, with whether the rule detects it and how that was shown, such
     as a fixture per part; every part the rule does not check is handled as an in-class miss
     below, whether or not the search found an instance of it;
   - every finding in the search file, marked as caught by the rule, inside the class and
     missed by the rule, or outside the class; for outside, the sentence clause 3.3 Part B asks
     for, stating why the hazard cannot arise there, and how it was confirmed by search;
   - for every in-class miss, the rule widened to catch it, with the commit, or the owner route
     below it went to, with its reason; on an owner route, every instance the search found
     there is still fixed at step 7 and counted in the fixed and remaining counts;
   - for each decision, the clause text it relies on, quoted verbatim from the copy you read.

   A rule narrower than the class you named is not finished. Clause 3.1: "If an independent
   search finds [Instances] the [Rule] missed, the [Class] was drawn too narrowly and the
   [Rule] MUST be widened until it catches them." Where the class's bounds sit is yours to
   decide under section 4, so widen the rule, commit it red again as step 4 did, and go on.
   The routes that leave it narrower are these, and each is recorded as such:

   - the ground section 4's last bullet names, that "the wider check is harder to build without
     [False positives]": name the code the wider check would wrongly match and refer the
     decision at step 7. That bullet goes on: "The [Instances] the search found are fixed
     regardless; what stays with the [Owner] is the [Class] left partly undefended." Fix them;
   - an exclusion of in-class code for which you cannot write clause 3.3 Part B's sentence:
     that is a suppression, the owner's under section 4, referred with the doubt stated. A
     finding inside the class you named is never relabelled as outside it;
   - a widening that no detector can express, a bespoke one included, because none is
     practical: a toolchain gap under clause 3.2, recorded where and as that clause says, with
     the rule built as far as it can go.

   Record what each of the search's two techniques found that the other could not have
   checked.

6. **Sweep and count.** Run the rule everywhere the pattern can occur: first-party source in
   every language it can occur in, generated and vendored code excluded, and record that scope
   as the project's decision when it had none. Check the tool scanned every file in that scope,
   since several skip files silently; each guide names the ones that do. Report the count.
   Narrow only to exclude code that does not carry the hazard, never to reduce the number.

7. **Fix every instance** within your authority, examining each; where one answer is right for
   all, say which were examined individually and which received it by pattern, and the sample
   you checked. Section 4 of the specification says which decisions are not yours: baselining,
   suppressing, leaving a known instance unfixed, or narrowing where you are unsure. Finish
   everything else, then refer those upward with the count fixed, the count remaining, what
   stopped you and what to try next, and leave the rule unmerged rather than weakened. Each
   referral in the report quotes, verbatim, the bullet of section 4's list of decisions that
   must go to the owner under which it falls. A decision that fits none of those bullets is
   yours under section 4's first list: do it rather than refer it. The one other referral is
   clause 3.2's: a toolchain gap you cannot record where the toolchain keeps its record is
   reported as a blocked decision, citing that clause.

8. **Make the rule permanent and blocking**, with a terse message and a stable identifier that
   resolves through the toolchain's resolver to documentation shipped with the project. Where
   the rule's host is new to the project, add its invocation to the entry point as the
   contract's entry-point section says. Run the project's own entry point, not the detector
   directly, see it green, and confirm the rule was loaded in that run. Read the CI
   configuration and record whether it runs that entry point; do not edit it.

9. **Fix the original defect** conventionally, with a test that reproduces it.

## 3. Review and report

Before the report issues, dispatch `defence-before-fix:conformance-reviewer` with the commit
that introduced the defence, the final commit, the project's entry point, the draft report, the
path to `SPEC.md`, the paths of the toolchain contract and the guides you used, the search
file, and the file to write its review to: `.dbf/reports/<date>-<class>-review.md`, beside the
search file, committed with the report. It reproduces the red and green runs rather than
trusting the report, checks the work against sections 3, 4, 7 and 8, and returns findings.
Resolve them or record why not. Findings are of two kinds, and resolve differently:

- **A finding about the work**, the rule, its proof, the sweep, the fixes or the tests, is
  resolved only by a commit that changes the work. Section 7 rests the verdict on reproduction,
  so dispatch the reviewer again on the new final commit; rewording the report resolves
  nothing.
- **A finding about the report itself**, such as a missing or late Scope decision, a quotation
  that is not verbatim, or a referral that does not quote its section 4 bullet, is resolved by
  revising the report. Dispatch the reviewer again with the revised report, the same commits
  and the earlier review, asking it to confirm the record findings only; the reproduction it
  already ran stands, because the commits it reproduced have not changed.

Committing the report, the search file and the review file is not a change to the work and
does not call for another review. The report issues only on a review of the work commits it
describes, and carries that review's verdict and findings as returned, against each the commit
or report revision that resolved it, or why it was not resolved.

Write the report using `${CLAUDE_SKILL_DIR}/references/REPORT-TEMPLATE.md`, every heading
filled. The report goes where the project keeps such records, or into the pull request
description if it has no such place. Where there is neither, write it to
`.dbf/reports/<date>-<class>.md` at the project root, with the date as YYYY-MM-DD and the class
as a short kebab-case name, and commit it with the remediation, the search file and the review
file. Open your final message with the line stating the specification version and source,
followed by the report's location.

## What this skill will not do

- Restate the method. The specification and the generated prompt are the only sources.
- Suppress, baseline or narrow on its own authority. Those are the owner's decisions.
- Touch CI, git hooks or branch policy. Section 8 places them outside the method.
- Change the project's manifest declaration.
