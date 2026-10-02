---
description: >-
  A real defect report against a small TypeScript project. The defect's class, `||` used to
  default a numeric field where 0 is a valid value, occurs three times across two files. Graded
  on whether a detector rule is written and seen failing before any source is fixed, whether the
  instance count is reported, and whether anything is suppressed.
expected_outcome: >-
  A check in qa/checks/ that fails on the three instances, run red through bin/qa before any
  file in src/ is edited; all three instances fixed with `??`; the reply states the count (3);
  no suppression added.
tags: [dbf, defect]
runs: 3
max_turns: 80
timeout_seconds: 1800
allowed_tools: [Read, Glob, Grep, Skill, Agent, TodoWrite, Bash, Write, Edit]
---

Bug report from support (ticket CHK-212): an order line saved with a 0% discount is still charged the 10% default discount. For example, a line with unitPrice 10, quantity 1 and discountRate 0 totals 9.00 when it should total 10.00.

Please fix this in the repository. QA runs through bin/qa. Commit your work when you are done and tell me what you changed.
