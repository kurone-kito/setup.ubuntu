#!/bin/sh
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

log() { printf '[unity] %s\n' "$*"; }
plan() { printf '[unity:plan] %s\n' "$*"; }

if ! command -v unity >/dev/null 2>&1
then
  echo "Error: the unity CLI is not on PATH. Run ./setup once (without --dry-run) first so lib/unity.sh installs it." >&2
  exit 1
fi

DRY_RUN=0
if [ "${1:-}" = "--dry-run" ]
then
  DRY_RUN=1
fi

# Measured against Unity's release API for LINUX/X86_64: both pinned
# Editors with the modules below total ~27 GiB installed. Kept as a
# single constant so the preflight threshold has one place to update.
REQUIRED_DISK_GIB=30

# Modules shared by both Editors. windows-mono is required for VRChat PC
# content, which builds as StandaloneWindows64.
MODULES="android linux-il2cpp windows-mono"

# The 6.3 stream has to be selected explicitly: Unity's "lts" alias is
# ambiguous between the 6000.0 and 6000.3 lines and can resolve to
# whichever line was patched most recently.
GENERAL_SELECTOR="6.3"
GENERAL_PREFIX="6000.3."

# The exact build VRChat's SDK targets. It is old enough that Unity's
# release list may not carry it by version alone, so the changeset pins
# the install either way.
VRCHAT_VERSION="2022.3.22f1"
VRCHAT_CHANGESET="887be4894c44"

# `unity install --dry-run --json` output is parsed with grep/sed instead
# of jq: this script can run before base-install.sh (a bare --unity
# --dry-run only needs the CLI, already required above), so jq is not
# guaranteed to be on PATH yet.
json_field() {
  printf '%s' "$1" | grep -o "\"$2\":[[:space:]]*\"[^\"]*\"" | head -1 | sed 's/.*"\([^"]*\)"$/\1/'
}

json_number_field() {
  printf '%s' "$1" | grep -o "\"$2\":[[:space:]]*[0-9]*" | head -1 | grep -o '[0-9]*$'
}

resolve() {
  # $1 = version selector, $2 = changeset (empty if none)
  if [ -n "$2" ]
  then
    # Word-splitting $MODULES is intentional: each module is its own -m
    # argument, and this script is POSIX sh so a bash array is not available.
    # shellcheck disable=SC2086
    unity install "$1" -c "$2" --dry-run --non-interactive --yes --json -m $MODULES --cm
  else
    # shellcheck disable=SC2086
    unity install "$1" --dry-run --non-interactive --yes --json -m $MODULES --cm
  fi
}

log "resolving general-games Editor (${GENERAL_SELECTOR})..."
general_json="$(resolve "$GENERAL_SELECTOR" "")"
general_version="$(json_field "$general_json" version)"

# Validated before extracting the size field below: under `set -e`, a
# missing/renamed JSON field would abort this script silently at that
# extraction, preempting this loud, specific error.
case "$general_version" in
  "${GENERAL_PREFIX}"*) ;;
  *)
    echo "Error: general-games selector '${GENERAL_SELECTOR}' resolved to '${general_version}', not a ${GENERAL_PREFIX}* build. Unity's 'lts' alias is ambiguous between release lines; refusing to install the wrong stream." >&2
    exit 1
    ;;
esac

general_size="$(json_number_field "$general_json" totalDownloadSize)"

log "resolving VRChat Editor (${VRCHAT_VERSION})..."
vrchat_json="$(resolve "$VRCHAT_VERSION" "$VRCHAT_CHANGESET")"
vrchat_version="$(json_field "$vrchat_json" version)"

if [ "$vrchat_version" != "$VRCHAT_VERSION" ]
then
  echo "Error: VRChat selector resolved to '${vrchat_version}', expected exactly '${VRCHAT_VERSION}'." >&2
  exit 1
fi

vrchat_size="$(json_number_field "$vrchat_json" totalDownloadSize)"

if [ "$DRY_RUN" -eq 1 ]
then
  plan "general games: ${general_version} (~$((general_size / 1024 / 1024 / 1024)) GiB download)"
  plan "VRChat: ${vrchat_version} changeset ${VRCHAT_CHANGESET} (~$((vrchat_size / 1024 / 1024 / 1024)) GiB download)"
  plan "modules (both editors): ${MODULES} (--cm)"
  plan "estimated disk required: ${REQUIRED_DISK_GIB} GiB"
  exit 0
fi

avail_kib="$(df -Pk "$HOME" | awk 'NR==2 {print $4}')"
avail_gib=$((avail_kib / 1024 / 1024))
if [ "$avail_gib" -lt "$REQUIRED_DISK_GIB" ]
then
  echo "Error: --unity needs ~${REQUIRED_DISK_GIB} GiB free at ${HOME}, but only ${avail_gib} GiB is available." >&2
  exit 1
fi

log "installing general-games Editor ${general_version}..."
# shellcheck disable=SC2086
unity install "$GENERAL_SELECTOR" --non-interactive --yes --accept-eula -m $MODULES --cm

log "installing VRChat Editor ${vrchat_version}..."
# shellcheck disable=SC2086
unity install "$VRCHAT_VERSION" -c "$VRCHAT_CHANGESET" --non-interactive --yes --accept-eula -m $MODULES --cm

log "done."
