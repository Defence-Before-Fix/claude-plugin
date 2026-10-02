---
type: regex
target: { source: file, path: src/pricing.ts }
match: not_contains
flags: i
pattern: 'eslint-disable|@ts-ignore|@ts-expect-error|@ts-nocheck|nosemgrep|noqa|nolint|qa[-:]?ignore|qa[-:]?allow|baseline'
---
