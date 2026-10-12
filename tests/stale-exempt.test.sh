#!/usr/bin/env bash
# Checks that stale.yml's exempt-issue-labels covers the IDD policy labels and
# the repository-only durable-record label. Prototype for the issue draft.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stale_workflow="${STALE_WORKFLOW:-$root/.github/workflows/stale.yml}"
idd_config="${IDD_CONFIG:-$root/.github/idd/config.json}"

# check_pair <stale.yml> <config.json>
# Prints the first missing required label to stderr and returns 1.
check_pair() {
  local workflow="$1" config="$2" value exempt label
  local -a required=()
  exempt="$(sed -n 's/^[[:space:]]*exempt-issue-labels:[[:space:]]*//p' "$workflow")"
  if [ -z "$exempt" ]; then
    echo "config error: exempt-issue-labels not found in $workflow" >&2
    return 1
  fi
  for key in labels.roadmapLabelName labels.blockedByHumanLabelName labels.needsDecisionLabelName; do
    value="$(jq -r ".$key // empty | select(. != \"\")" "$config")"
    if [ -z "$value" ]; then
      echo "config error: $key missing or empty in $config" >&2
      return 1
    fi
    required+=("$value")
  done
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

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# negative_case <name> <expected substring> <target: workflow|config> <sed expression>
# The copy is changed with one anchored sed expression. check_pair must fail
# and print the expected substring. The script itself is never re-run.
negative_case() {
  local name="$1" expect="$2" target="$3" expr="$4" out wf cfg
  local repo_wf="$root/.github/workflows/stale.yml" repo_cfg="$root/.github/idd/config.json"
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

negative_case "a: status:authoring removed" "status:authoring" workflow 's/,status:authoring//'
negative_case "b: roadmap renamed in config" "roadmap-renamed" config 's/"roadmapLabelName": "roadmap"/"roadmapLabelName": "roadmap-renamed"/'
negative_case "c: durable-record removed" "durable-record" workflow 's/,durable-record//'
negative_case "d: needs-decision substring" "needs-decision" config 's/"needsDecisionLabelName": "status:needs-decision"/"needsDecisionLabelName": "needs-decision"/'

if [ "$fail" -eq 0 ]; then
  echo "ok: positive check"
fi
exit "$fail"
