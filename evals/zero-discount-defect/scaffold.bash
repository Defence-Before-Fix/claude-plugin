#!/usr/bin/env bash
# Seeds the run's empty workspace with the fixture project as a one-commit git repository.
set -euo pipefail
case_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp -R "$case_dir/fixture/." .
chmod 755 bin/qa qa/checks/no-console-log
git init -q -b main
git config user.name 'Checkout Developer'
git config user.email 'checkout@example.invalid'
git add -A
git commit -q -m 'checkout-pricing: initial import'
