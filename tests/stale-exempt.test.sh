#!/usr/bin/env bash
# Checks that stale.yml's exempt-issue-labels covers the IDD policy labels and
# the repository-only durable-record label. The negative cases are built from
# the repository's own values with jq and awk, not with sed expressions, so
# label names containing regex or delimiter characters do not break them.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stale_workflow="${STALE_WORKFLOW:-$root/.github/workflows/stale.yml}"
idd_config="${IDD_CONFIG:-$root/.github/idd/config.json}"

# exempt_tokens <stale.yml>: prints the trimmed tokens of exempt-issue-labels, one per line.
exempt_tokens() {
  local exempt
  exempt="$(sed -n 's/^[[:space:]]*exempt-issue-labels:[[:space:]]*//p' "$1")"
  printf '%s\n' "$exempt" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# read_required <config.json> <key>: prints the value, or fails with a named error.
read_required() {
  local value
  value="$(jq -r ".$2 // empty | select(. != \"\")" "$1")"
  if [ -z "$value" ]; then
    echo "config error: $2 missing or empty in $1" >&2
    return 1
  fi
  printf '%s' "$value"
}

# check_pair <stale.yml> <config.json>
# Prints the first missing required label to stderr and returns 1.
check_pair() {
  local workflow="$1" config="$2" exempt label value
  local -a required=()
  exempt="$(sed -n 's/^[[:space:]]*exempt-issue-labels:[[:space:]]*//p' "$workflow")"
  if [ -z "$exempt" ]; then
    echo "config error: exempt-issue-labels not found in $workflow" >&2
    return 1
  fi
  required+=("$(read_required "$config" labels.roadmapLabelName)") || return 1
  required+=("$(read_required "$config" labels.blockedByHumanLabelName)") || return 1
  required+=("$(read_required "$config" labels.needsDecisionLabelName)") || return 1
  value="$(jq -r '.issueAuthoring.authoringLabelName // empty | select(. != "")' "$config")"
  required+=("${value:-status:authoring}")
  required+=("durable-record")
  for label in "${required[@]}"; do
    if ! exempt_tokens "$workflow" | grep -Fxq -- "$label"; then
      echo "missing from exempt-issue-labels: $label" >&2
      return 1
    fi
  done
}

fail=0
if ! check_pair "$stale_workflow" "$idd_config"; then
  echo "FAIL: positive check" >&2
  fail=1
fi

# The negative cases start from the repository's own files, never the overrides.
repo_wf="$root/.github/workflows/stale.yml"
repo_cfg="$root/.github/idd/config.json"
roadmap="$(read_required "$repo_cfg" labels.roadmapLabelName)"
needs="$(read_required "$repo_cfg" labels.needsDecisionLabelName)"
authoring="$(jq -r '.issueAuthoring.authoringLabelName // empty | select(. != "")' "$repo_cfg")"
authoring="${authoring:-status:authoring}"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# drop_token <src stale.yml> <dst> <label>: copies the file and removes one whole
# token from the exempt-issue-labels value. Comparison is exact, not a regex.
drop_token() {
  awk -v label="$3" '
    /^[[:space:]]*exempt-issue-labels:/ {
      head = $0; sub(/exempt-issue-labels:.*$/, "", head)
      value = $0; sub(/^.*exempt-issue-labels:[[:space:]]*/, "", value)
      n = split(value, parts, ",")
      out = ""
      for (i = 1; i <= n; i++) {
        p = parts[i]; gsub(/^[[:space:]]+|[[:space:]]+$/, "", p)
        if (p == label) continue
        out = (out == "" ? p : out "," p)
      }
      print head "exempt-issue-labels: " out
      next
    }
    { print }
  ' "$1" > "$2"
}

# negative_result <name> <expected substring> <stale.yml copy> <config copy>
# The copies must differ from the repository files, check_pair must fail, and its
# output must contain the expected substring. The script itself is never re-run.
negative_result() {
  local name="$1" expect="$2" wf="$3" cfg="$4" out
  if cmp -s "$wf" "$repo_wf" && cmp -s "$cfg" "$repo_cfg"; then
    echo "FAIL: $name: the copy is identical to the repository file" >&2
    fail=1
    return
  fi
  if out="$(check_pair "$wf" "$cfg" 2>&1)"; then
    echo "FAIL: $name: check passed on a changed copy" >&2
    fail=1
  elif ! grep -Fq -- "$expect" <<<"$out"; then
    echo "FAIL: $name: output lacks '$expect': $out" >&2
    fail=1
  else
    echo "ok: $name"
  fi
}

drop_token "$repo_wf" "$tmp/stale-a.yml" "$authoring"
negative_result "a: authoring label removed" "$authoring" "$tmp/stale-a.yml" "$repo_cfg"

jq --arg v "$roadmap-renamed" '.labels.roadmapLabelName = $v' "$repo_cfg" > "$tmp/config-b.json"
negative_result "b: roadmap renamed in config" "$roadmap-renamed" "$repo_wf" "$tmp/config-b.json"

drop_token "$repo_wf" "$tmp/stale-c.yml" durable-record
negative_result "c: durable-record removed" "durable-record" "$tmp/stale-c.yml" "$repo_cfg"

# A proper substring of the needs-decision label, never equal to it.
if exempt_tokens "$repo_wf" | grep -Fxq -- "${needs:1}"; then
  echo "FAIL: d: ${needs:1} is itself an exempt token, so case d cannot test whole-token matching" >&2
  fail=1
fi
jq --arg v "${needs:1}" '.labels.needsDecisionLabelName = $v' "$repo_cfg" > "$tmp/config-d.json"
negative_result "d: needs-decision substring" "${needs:1}" "$repo_wf" "$tmp/config-d.json"

if [ "$fail" -eq 0 ]; then
  echo "ok: positive check"
fi
exit "$fail"
