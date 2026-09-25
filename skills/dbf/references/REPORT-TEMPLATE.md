# Defence Before Fix report

Fill every heading. Where a heading does not apply, say so and why rather than deleting it.
The report is the record the codebase owner reads; it must stand on its own.

## Specification followed

Method specification version, and whether the copy read was vendored, cached or fetched, as
printed by the refresh script.

## Toolchain

The languages detected, with the toolchain guide used for each or a note that none existed and
the contract was filled from the fallback guide. The toolchain detected (from the manifest
declaration and the tools register), the spec versions it declares, the project's entry point,
and the commands used for listing, identifier resolution and the single-rule harness. The rule
host chosen, where it stands in the contract's rule-host order, and why; any detector the project
gained, and how its invocation was added to the entry point. Where the project had recorded no
calibration, the calibration assumed.

## Defect and class

The originating instance (file and line), the class it belongs to, and the hazard the class
carries. If no class could be attributed, say so; the method's Appendix A then allows a
conventional fix, and the rest of this report records that.

## Rule

The detector the rule was written in, the rule's stable identifier, its message, and where its
documentation lives in the project. State how wide the rule is drawn and what it deliberately
excludes as not carrying the hazard. Name the next wider rule considered and why it was not
built.

## Proof

How the rule was shown to fire: on the originating instance, or on a kept fixture, with the
command run and its output, and the commit in which the red proof survives on its own.

## Independent search

What the independent searcher looked for, before the rule existed and without sight of it.
What text search found that reading could not have checked, and what reading found that text
search could not have. Which instances the search found that the rule initially missed, and
how the rule was widened in response. The search wins over the rule.

## Sweep and count

The sweep scope: first-party source in every language the pattern can occur in, generated and
vendored code excluded, recorded as the project's decision where it had none. Everywhere the
rule was run and the total instance count. Any narrowing applied, with the reason it excludes
hazard-free code only.

## Fixes

Every instance fixed, and how. Which were examined individually, which received the change by
pattern, and the sample checked. Confirm that no instance was satisfied by suppressing the rule
or by leaving the hazard in place.

## Decisions referred to the owner

Each decision outside the practitioner's authority under section 4 of the method specification:
what it is, the count fixed and the count remaining, what stopped the fixing, what to try next,
and what fixing it would take. State that the rule is left unmerged rather than weakened, or
merged at full width with a recorded known instance where the specification allows that.

## Permanence

The rule's place in the project's blocking checks, and the green run through the project's own
entry point rather than the detector directly. Whether the project's CI runs that entry point,
as read from its configuration, which this run did not change.

## Toolchain and detector gaps

Anything the toolchain or the detector failed to offer that the specifications say it must,
reported rather than worked around.

## The original defect

The conventional fix, and the test that reproduces the defect and now passes.
