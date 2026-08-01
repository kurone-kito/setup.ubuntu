#!/bin/sh
# -*- mode: sh -*-
# vim: set ft=sh :

# Non-mutating smoke test for setup's CLI argument surface. Every case here
# reaches its outcome before setup would install anything or invoke sudo, so
# this test runs the real ./setup directly rather than mocking its parser.

set -eu
cd "$(cd "$(dirname "$0")/.."; pwd)"

# Clear the desktop env vars so an ambient value from the caller's
# environment cannot change a case's expected outcome.
unset DESKTOP_DRY_RUN DESKTOP_SUNSHINE_WSL DESKTOP_DUMMY_DISPLAY

FAILURES=0

# Runs setup with the given arguments/environment and checks the exit status
# and a distinguishing (not exact-wording) output substring.
check() {
  name="$1"
  expected_status="$2"
  expected_substring="$3"
  shift 3

  set +e
  output="$("$@" 2>&1)"
  actual_status=$?
  set -e

  ok=1
  if [ "${actual_status}" -ne "${expected_status}" ]
  then
    ok=0
    printf 'FAIL: %s: expected exit %s, got %s\n' "${name}" "${expected_status}" "${actual_status}" >&2
  fi
  if ! printf '%s\n' "${output}" | grep -qF "${expected_substring}"
  then
    ok=0
    printf 'FAIL: %s: expected output to contain %s\n' "${name}" "${expected_substring}" >&2
  fi
  if [ "${ok}" -eq 1 ]
  then
    printf 'PASS: %s\n' "${name}"
  else
    FAILURES=$((FAILURES + 1))
  fi
}

check "help (-h)" 0 "Usage:" ./setup -h
check "help (--help)" 0 "Usage:" ./setup --help
check "unknown flag" 1 "Usage:" ./setup --not-a-real-flag
check "stray positional after --" 1 "Usage:" ./setup -- extra-positional
check "--dry-run" 0 "[desktop:plan]" ./setup --dry-run
check "DESKTOP_DRY_RUN=true env var" 0 "[desktop:plan]" env DESKTOP_DRY_RUN=true ./setup
check "--desktop -v rejected on the VM path" 1 "not supported" ./setup --desktop -v
check "--desktop -v --dry-run is exempt" 0 "[desktop:plan]" ./setup --desktop -v --dry-run

if [ "${FAILURES}" -gt 0 ]
then
  printf '%s case(s) failed\n' "${FAILURES}" >&2
  exit 1
fi

echo "all setup CLI smoke test cases passed"
