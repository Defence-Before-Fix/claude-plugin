#!/usr/bin/env bash
#
# Fails when the versions declared in the vendored specification snapshot do
# not match SPEC-VERSION, so a snapshot refresh cannot land without the pin
# being updated alongside it.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
spec="$root/skills/dbf/references/spec"

declared() {
  local key="$1"
  local line
  if line="$(grep -m1 -E "^${key}=" "$root/SPEC-VERSION")"; then
    echo "${line#*=}"
  else
    echo "check-spec-version: SPEC-VERSION has no ${key}= line" >&2
    exit 1
  fi
}

vendored() {
  local file="$1"
  local line
  if line="$(grep -m1 -E '^\*\*Version\*\*: ' "$file")"; then
    line="${line#\*\*Version\*\*: }"
    echo "${line%%,*}"
  else
    echo "check-spec-version: $file declares no version" >&2
    exit 1
  fi
}

status=0
for pair in "method:SPEC.md" "detector:DETECTOR-SPEC.md" "toolchain:TOOLING-SPEC.md"; do
  key="${pair%%:*}"
  file="${pair#*:}"
  want="$(declared "$key")"
  have="$(vendored "$spec/$file")"
  if [[ "$want" == "$have" ]]; then
    echo "ok   $key $have"
  else
    echo "FAIL $key: SPEC-VERSION says $want, $file says $have"
    status=1
  fi
done
exit "$status"
