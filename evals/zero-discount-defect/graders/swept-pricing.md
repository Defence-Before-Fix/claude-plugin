---
type: regex
target: { source: file, path: src/pricing.ts }
match: not_contains
pattern: '\|\|'
---

Passes when no `||` default is left in src/pricing.ts: the reported instance (discountRate) and
its sibling (quantity) are both fixed.
