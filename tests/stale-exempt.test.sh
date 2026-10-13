#!/usr/bin/env bash
# Checks that stale.yml's exempt-issue-labels covers the IDD policy labels and
# the repository-only durable-record label. The negative cases derive their
# sed expressions from the repository's current config values, so a legitimate
# rename of a policy label does not break them.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stale_workflow="${STALE_WORKFLOW:-$root/.github/workflows/stale.yml}"
idd_config="${IDD_CONFIG:-$root/.github/idd/config.json}"

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
    if ! printf '%s\n' "$exempt" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -Fxq -- "$label"; then
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

# The negative cases read the repository's own values, never the overrides.
repo_wf="$root/.github/workflows/stale.yml"
repo_cfg="$root/.github/idd/config.json"
roadmap="$(read_required "$repo_cfg" labels.roadmapLabelName)"
needs="$(read_required "$repo_cfg" labels.needsDecisionLabelName)"
authoring="$(jq -r '.issueAuthoring.authoringLabelName // empty | select(. != "")' "$repo_cfg")"
authoring="${authoring:-status:authoring}"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# negative_case <name> <expected substring> <target: workflow|config> <sed expression>
# Copies the repository file, applies one sed expression to the copy, and calls
# check_pair on the copies. It must fail, and its output must contain the
# expected substring. The script itself is never re-run.
negative_case() {
  local name="$1" expect="$2" target="$3" expr="$4" out wf cfg
  wf="$repo_wf"; cfg="$repo_cfg"
  if [ "$target" = workflow ]; then
    sed -e "$expr" "$repo_wf" > "$tmp/stale.yml"; wf="$tmp/stale.yml"
  else
    sed -e "$expr" "$repo_cfg" > "$tmp/config.json"; cfg="$tmp/config.json"
  fi
  if cmp -s "$wf" "$repo_wf" && cmp -s "$cfg" "$repo_cfg"; then
    echo "FAIL: $name: the sed expression changed nothing" >&2
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

negative_case "a: authoring label removed" "$authoring" workflow \
  "/exempt-issue-labels:/s|,$authoring\\b||"
negative_case "b: roadmap renamed in config" "$roadmap-renamed" config \
  "s|\"roadmapLabelName\": \"$roadmap\"|\"roadmapLabelName\": \"$roadmap-renamed\"|"
negative_case "c: durable-record removed" "durable-record" workflow \
  "/exempt-issue-labels:/s|,durable-record\\b||"
negative_case "d: needs-decision substring" "${needs#*:}" config \
  "s|\"needsDecisionLabelName\": \"$needs\"|\"needsDecisionLabelName\": \"${needs#*:}\"|"

if [ "$fail" -eq 0 ]; then
  echo "ok: positive check"
fi
exit "$fail"
