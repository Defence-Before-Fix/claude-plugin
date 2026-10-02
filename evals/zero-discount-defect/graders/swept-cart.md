---
type: regex
target: { source: file, path: src/cart.ts }
match: not_contains
pattern: '\|\|'
---

Passes when the instance in the other file (shippingFee), which the report does not mention, is
fixed too.
