#!/usr/bin/env bash
#
# refresh-spec.bash: resolve which copy of each Defence Before Fix document the
# skill should read, refreshing a cached copy from the canonical site when the
# cache is older than the TTL and the network allows.
#
# Prints one line per document:  <name>  <source>  <version>  <path>
# where <source> is vendored, cached or fetched. Exits non-zero only when the
# vendored snapshot itself is missing or an argument is malformed; a failed or
# malformed fetch is reported and the vendored or cached copy is used instead.
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
    --ttl)
      ttl="${2:-}"
      shift 2 || { echo "refresh-spec: --ttl needs a value" >&2; exit 2; }
      ;;
    --offline) offline=1; shift ;;
    --force) force=1; shift ;;
    *) echo "refresh-spec: unknown argument $1" >&2; exit 2 ;;
  esac
done
if [[ ! "$ttl" =~ ^[0-9]+$ ]]; then
  echo "refresh-spec: --ttl must be a whole number of seconds, got '$ttl'" >&2
  exit 2
fi

# Where the cache lives. With no data directory and no home, there is nowhere
# durable to cache, so the run is vendored-only.
cacheDir=""
if [[ -n "${CLAUDE_PLUGIN_DATA:-}" ]]; then
  cacheDir="$CLAUDE_PLUGIN_DATA/spec"
elif [[ -n "${XDG_CACHE_HOME:-}" ]]; then
  cacheDir="$XDG_CACHE_HOME/defence-before-fix/spec"
elif [[ -n "${HOME:-}" ]]; then
  cacheDir="$HOME/.cache/defence-before-fix/spec"
fi

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

# A fetched file must look like the document it claims to be before it may
# displace a good copy: a captive portal or an error page can arrive with 200.
looksRight() {
  local name="$1" file="$2"
  case "$name" in
    SPEC.md|DETECTOR-SPEC.md|TOOLING-SPEC.md)
      [[ "$(versionOf "$file")" != "-" ]]
      ;;
    project-prompt.md)
      [[ "$(head -c 22 "$file")" == "# Defence Before Fix" ]] || grep -q -m1 -E '^# Defence Before Fix' "$file"
      ;;
    register.json)
      [[ "$(head -c 1 "$file")" == "{" ]]
      ;;
    *)
      return 1
      ;;
  esac
}

# Age of the cache in seconds; a missing or malformed stamp counts as ancient.
cacheAge() {
  local stampFile="$1"
  local now fetchedAt
  if [[ ! -f "$stampFile" ]]; then
    echo 999999999
    return
  fi
  fetchedAt="$(cat "$stampFile")"
  if [[ ! "$fetchedAt" =~ ^[0-9]+$ ]]; then
    echo 999999999
    return
  fi
  now="$(date +%s)"
  echo $((now - fetchedAt))
}

# True when every document is present in the cache; a partial set is stale.
cacheComplete() {
  local entry name
  for entry in "${docs[@]}"; do
    IFS='|' read -r name _ _ <<<"$entry"
    if [[ ! -f "$cacheDir/$name" ]]; then
      return 1
    fi
  done
  return 0
}

fetched=0
notes=()
if [[ -n "$cacheDir" ]]; then
  stamp="$cacheDir/.fetched"
  age="$(cacheAge "$stamp")"
  stale=0
  if ((force == 1)) || ((age >= ttl)); then
    stale=1
  elif ! cacheComplete; then
    stale=1
    if [[ "$offline" != "1" ]]; then
      notes+=("cache was incomplete, refreshing the whole set")
    fi
  fi
  if [[ "$offline" != "1" ]] && ((stale == 1)); then
    if ! command -v curl >/dev/null; then
      notes+=("curl not found, cannot fetch")
    else
      mkdir -p "$cacheDir"
      tmpDir="$(mktemp -d "$cacheDir/.fetch.XXXXXX")"
      ok=1
      for entry in "${docs[@]}"; do
        IFS='|' read -r name _ remote <<<"$entry"
        if ! curl -fsS --max-time 20 -o "$tmpDir/$name" "$site/$remote"; then
          ok=0
          notes+=("fetch of $site/$remote failed")
          break
        fi
        if ! looksRight "$name" "$tmpDir/$name"; then
          ok=0
          notes+=("fetched $site/$remote does not look like $name, discarded")
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
  fi
fi

useCache=0
if [[ -n "$cacheDir" ]] && cacheComplete; then
  useCache=1
elif [[ -n "$cacheDir" && -d "$cacheDir" ]] && [[ "$offline" == "1" ]] && ! cacheComplete; then
  if [[ -n "$(ls -A "$cacheDir" 2>&1)" ]]; then
    notes+=("cache incomplete and offline, using the vendored set")
  fi
fi

for entry in "${docs[@]}"; do
  IFS='|' read -r name vendoredFile _ <<<"$entry"
  if ((useCache == 1)); then
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

for note in "${notes[@]}"; do
  echo "refresh-spec: $note" >&2
done
if [[ "$offline" == "1" ]]; then
  echo "refresh-spec: offline, network not attempted" >&2
fi
