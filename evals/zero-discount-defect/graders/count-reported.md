---
type: regex
target: last_message
flags: i
pattern: '\b(?:3|three)\b[^.\n]{0,60}\b(?:instances?|occurrences?|places|sites|locations|matches|violations|hits|findings|call ?sites)\b|\b(?:instances?|occurrences?|violations|matches|count)\b[^.\n]{0,40}\b(?:3|three)\b'
---

Passes when the final reply states that the class occurs three times: `||` defaulting a
numeric field where 0 is valid, at item.quantity and item.discountRate in src/pricing.ts and
cart.shippingFee in src/cart.ts.
