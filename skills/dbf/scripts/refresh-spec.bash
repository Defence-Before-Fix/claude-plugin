#!/usr/bin/env bash
#
# refresh-spec.bash: resolve which copy of each Defence Before Fix document the
# skill should read, refreshing a cached copy from the canonical site when the
# cache is older than the TTL and the network allows.
#
# Prints one line per document:  <name>  <source>  <version>  <path>
# where <source> is vendored, cached or fetched. Exits non-zero only when the
# vendored snapshot itself is missing; a failed fetch is reported and the
# vendored or cached copy is used instead.
#
# Usage: refresh-spec.bash [--ttl SECONDS] [--offline] [--force]
#   --ttl      cache lifetime in seconds (default 86400, env DBF_SPEC_TTL)
#   --offline  never touch the network (env DBF_SPEC_OFFLINE=1)
#   --force    fetch regardless of cache age

set -euo pipefail

skillDir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
vendoredDir="$skillDir/references/spec"
site="https://defence-before-fix.github.io"

ttl="${DBF_SPEC_TTL:-86400}"
offline="${DBF_SPEC_OFFLINE:-0}"
force=0
while (($# > 0)); do
  case "$1" in
    --ttl) ttl="$2"; shift 2 ;;
    --offline) offline=1; shift ;;
    --force) force=1; shift ;;
    *) echo "refresh-spec: unknown argument $1" >&2; exit 2 ;;
  esac
done

if [[ -n "${CLAUDE_PLUGIN_DATA:-}" ]]; then
  cacheDir="$CLAUDE_PLUGIN_DATA/spec"
else
  cacheDir="${XDG_CACHE_HOME:-$HOME/.cache}/defence-before-fix/spec"
fi
stamp="$cacheDir/.fetched"

# name|vendored file|remote path
docs=(
  "SPEC.md|SPEC.md|raw/SPEC.md"
  "DETECTOR-SPEC.md|DETECTOR-SPEC.md|raw/DETECTOR-SPEC.md"
  "TOOLING-SPEC.md|TOOLING-SPEC.md|raw/TOOLING-SPEC.md"
  "project-prompt.md|project-prompt.md|defence-before-fix-project-prompt.md"
  "register.json|register.json|tools/register.json"
)

for entry in "${docs[@]}"; do
  IFS='|' read -r _ vendoredFile _ <<<"$entry"
  if [[ ! -f "$vendoredDir/$vendoredFile" ]]; then
    echo "refresh-spec: vendored snapshot missing: $vendoredDir/$vendoredFile" >&2
    exit 1
  fi
done

# Print the document's declared version, or "-" when it declares none.
versionOf() {
  local file="$1"
  local line
  if line="$(grep -m1 -E '^\*\*Version\*\*: ' "$file")"; then
    line="${line#\*\*Version\*\*: }"
    echo "${line%%,*}"
  else
    echo "-"
  fi
}

cacheAge() {
  if [[ ! -f "$stamp" ]]; then
    echo 999999999
    return
  fi
  local now fetchedAt
  now="$(date +%s)"
  fetchedAt="$(cat "$stamp")"
  echo $((now - fetchedAt))
}

fetched=0
fetchNote=""
age="$(cacheAge)"
if [[ "$offline" != "1" ]] && { ((force == 1)) || ((age >= ttl)); }; then
  mkdir -p "$cacheDir"
  tmpDir="$(mktemp -d "$cacheDir/.fetch.XXXXXX")"
  ok=1
  for entry in "${docs[@]}"; do
    IFS='|' read -r name _ remote <<<"$entry"
    if ! curl -fsS --max-time 20 -o "$tmpDir/$name" "$site/$remote"; then
      ok=0
      fetchNote="fetch of $site/$remote failed"
      break
    fi
  done
  if ((ok == 1)); then
    for entry in "${docs[@]}"; do
      IFS='|' read -r name _ _ <<<"$entry"
      mv -f "$tmpDir/$name" "$cacheDir/$name"
    done
    date +%s >"$stamp"
    fetched=1
  fi
  rm -rf "$tmpDir"
fi

for entry in "${docs[@]}"; do
  IFS='|' read -r name vendoredFile _ <<<"$entry"
  if [[ -f "$cacheDir/$name" ]]; then
    if ((fetched == 1)); then
      source="fetched"
    else
      source="cached"
    fi
    path="$cacheDir/$name"
  else
    source="vendored"
    path="$vendoredDir/$vendoredFile"
  fi
  if [[ "$name" == *.md ]]; then
    version="$(versionOf "$path")"
  else
    version="-"
  fi
  printf '%s\t%s\t%s\t%s\n' "$name" "$source" "$version" "$path"
done

if [[ -n "$fetchNote" ]]; then
  echo "refresh-spec: $fetchNote; using the copy listed above" >&2
fi
if [[ "$offline" == "1" ]]; then
  echo "refresh-spec: offline, network not attempted" >&2
fi
