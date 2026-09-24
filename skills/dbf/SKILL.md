---
name: dbf
description: Run the Defence Before Fix (DBF) method on a defect. Use whenever the user says "DBF", "Defence Before Fix", "defence before fix this", or asks you to fix a bug, a defect, a failing check or a red QA run in a project; and whenever a QA tool prints "Defence Before Fix" in its failure output. Before fixing anything, this skill attributes the defect to a class, writes and proves a detector rule for the class, sweeps and fixes every instance, and only then fixes the original defect.
argument-hint: "[description of the defect, or a file:line, or blank to work from the current failure]"
disable-model-invocation: false
user-invocable: true
allowed-tools: Agent, Bash, Read, Grep, Glob, Write, Edit
---

# Defence Before Fix

The method specification is the contract; this file is the runbook that applies it. Every step
below names the document and section that governs it. Do not paraphrase the method from
memory: read the copy the refresh script gives you.

## 0. Load the specification

Run the refresh script and read the project prompt it names:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/dbf/scripts/refresh-spec.bash"
```

It prints one line per document with the source (vendored, cached or fetched), the version and
the path. Read `project-prompt.md` in full now; it is the method in the form an agent follows,
generated from the specification's Appendix A. Read `SPEC.md` section 4 (authority) before any
decision about narrowing, excluding or leaving an instance, and section 3 whenever a step
below is unclear. State the version and source in the report.

The refresh script never fails on a network error. If it reports a failed fetch, carry on with
the copy it listed.

## 1. Discover the project's toolchain

Do this before writing anything, so you know what is already defended.

- Read the manifest declaration: `extra.defence-before-fix` in `composer.json`, or
  `defenceBeforeFix` in `package.json`. Accept both `known-gaps` and `knownGaps` as the
  known-gap key. Note the method, detector and toolchain versions it declares. Never add or
  change the declaration; report what you found.
- Identify the toolchain and look it up in `register.json` from the refresh script. The
  register names each tool's commands for listing defences, resolving an identifier to its
  documentation, and running a single rule against a path.
- Run the listing first. The specification's clause 8.5 requires defences to be enumerable
  without triggering them, and the listing tells you whether the class is already defended and
  what the project has recorded as exceptions.
- If the project has no toolchain graded in the register, choose a detector for the language
  from the register, preferring one graded green for detector conformance, and say in the
  report what the project's tooling lacks.

## 2. Follow the method

The project prompt gives the order and the rules. In outline:

1. **Attribute** the instance to a class and name the hazard. If no class can be written as a
   rule, say so and fall back to the conventional fix the prompt allows.
2. **Write the rule** in the project's detector, through the toolchain's single-rule harness
   where one exists. Draw it wider than the one instance and no wider than the hazard.
3. **Search independently.** Dispatch the `defence-before-fix:independent-searcher` agent
   with the class and the hazard, and nothing about the rule. Its fresh context is what makes
   the search independent. Where its findings exceed the rule's, widen the rule; the search
   wins.
4. **Prove the rule fires** on the originating instance or on a fixture you keep as its test.
5. **Sweep and count.** Run the rule everywhere the pattern can occur and report the count.
   Narrow only to exclude code that does not carry the hazard, never to reduce the number.
6. **Fix every instance** within your authority. Section 4 of the specification says which
   decisions are not yours: baselining, suppressing, leaving a known instance unfixed, or
   narrowing where you are unsure. Finish everything else, then refer those upward with the
   count and the cost, and leave the rule unmerged rather than weakened.
7. **Make the rule permanent and blocking**, with a terse message and a stable identifier that
   resolves through the toolchain's resolver to documentation shipped with the project. Run it
   yourself and read its output.
8. **Fix the original defect** conventionally, with a test that reproduces it.

## 3. Review and report

Before the report issues, dispatch the `defence-before-fix:conformance-reviewer` agent with
the branch or diff and the draft report. It checks the remediation against sections 3, 4 and 8
of the method specification and returns findings. Resolve them or record why not.

Write the report using `references/REPORT-TEMPLATE.md`, every heading filled. The report goes
where the project keeps such records, or into the pull request description if it has no such
place.

## What this skill will not do

- Restate the method. The specification and the generated prompt are the only sources.
- Suppress, baseline or narrow on its own authority. Those are the owner's decisions.
- Touch CI, git hooks or branch policy. Section 8 places them outside the method.
- Change the project's manifest declaration.
