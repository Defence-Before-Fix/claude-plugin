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
bash "${CLAUDE_SKILL_DIR}/scripts/refresh-spec.bash"
```

In a harness that does not expand that variable, the script is at `scripts/refresh-spec.bash`
relative to this file. It prints one line per document with the source (vendored, cached or
fetched), the version and the path. Read `project-prompt.md` in full now; it is the method in
the form an agent follows, generated from the specification's Appendix A. Read `SPEC.md`
section 4 (authority) before any decision about narrowing, excluding or leaving an instance,
and section 3 whenever a step below is unclear. State the version and source in the report.

The refresh script never fails on a network error. If it reports a failed fetch, carry on with
the copy it listed.

## 1. Discover the project's toolchain

Do this before writing anything, so you know what is already defended.

- Read the manifest declaration where the ecosystem records dependencies. The toolchain
  specification's clause 9.2 fixes no key; the reference toolchains use
  `extra.defence-before-fix` in `composer.json` and `defenceBeforeFix` in `package.json`, and
  spell the known-gap record `known-gaps` or `knownGaps`. Report whatever form you find. Never
  add or change the declaration.
- Identify the toolchain. `register.json` from the refresh script is the graded index of tools
  by language with a page link per tool; it does not carry commands. The commands for the two
  reference toolchains are in `references/spec/tools/php-qa-ci.md` and
  `references/spec/tools/ts-qa-ci.md` beside this file; for any other tool, the installed
  package's own documentation is the source.
- Run the listing first. The specification's clause 8.5 requires defences to be enumerable
  without triggering them, and the listing tells you whether the class is already defended and
  what the project has recorded as exceptions. Where the project has recorded nothing, note the
  calibration you assume, because the report must say so.
- If the project has no toolchain graded in the register, choose a detector for the language
  from the register, preferring one graded green for detector conformance, and say in the
  report what the project's tooling lacks.

## 2. Follow the method

The project prompt gives the order and the rules. In outline:

1. **Attribute** the instance to a class and name the hazard, in one sentence you can hand to
   someone else. If no class can be written as a rule, say so and fall back to the conventional
   fix the prompt allows.
2. **Dispatch the independent searcher now**, before any rule exists, so that its search would
   exist unchanged had the rule never been written. Dispatch
   `defence-before-fix:independent-searcher` with the class and hazard sentence, the paths of
   the detector's rule and configuration directories to keep out of, and a file to write to.
   Let it run whilst you write the rule.
3. **Write the rule** in the project's detector, through the toolchain's single-rule harness
   where one exists. Draw it wider than the one instance and no wider than the hazard. Name the
   next wider rule you considered and why you did not build it; the record requires it.
4. **Prove the rule fires** on the originating instance or on a fixture you keep as its test,
   and commit the defence red, as a commit of its own, before any instance is fixed.
5. **Reconcile with the search.** Where the searcher's findings exceed the rule's, widen the
   rule; the search wins. Record what each of its two techniques found that the other could not
   have checked.
6. **Sweep and count.** Run the rule everywhere the pattern can occur: first-party source in
   every language it can occur in, generated and vendored code excluded, and record that scope
   as the project's decision when it had none. Report the count. Narrow only to exclude code
   that does not carry the hazard, never to reduce the number.
7. **Fix every instance** within your authority, examining each; where one answer is right for
   all, say which were examined individually and which received it by pattern, and the sample
   you checked. Section 4 of the specification says which decisions are not yours: baselining,
   suppressing, leaving a known instance unfixed, or narrowing where you are unsure. Finish
   everything else, then refer those upward with the count fixed, the count remaining, what
   stopped you and what to try next, and leave the rule unmerged rather than weakened.
8. **Make the rule permanent and blocking**, with a terse message and a stable identifier that
   resolves through the toolchain's resolver to documentation shipped with the project. Run the
   project's own entry point, not the detector directly, and see it green.
9. **Fix the original defect** conventionally, with a test that reproduces it.

## 3. Review and report

Before the report issues, dispatch `defence-before-fix:conformance-reviewer` with the commit
that introduced the defence, the final commit, the project's entry point, the draft report and
the path to `SPEC.md`. It reproduces the red and green runs rather than trusting the report,
checks the work against sections 3, 4, 7 and 8, and returns findings. Resolve them or record
why not.

Write the report using `${CLAUDE_SKILL_DIR}/references/REPORT-TEMPLATE.md`, every heading
filled. The report goes where the project keeps such records, or into the pull request
description if it has no such place.

## What this skill will not do

- Restate the method. The specification and the generated prompt are the only sources.
- Suppress, baseline or narrow on its own authority. Those are the owner's decisions.
- Touch CI, git hooks or branch policy. Section 8 places them outside the method.
- Change the project's manifest declaration.
