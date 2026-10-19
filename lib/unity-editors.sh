#!/bin/sh
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

log() { printf '[unity] %s\n' "$*"; }
plan() { printf '[unity:plan] %s\n' "$*"; }

# Falls back to the vendor installer's default xdg-layout location: the
# CLI may already be installed there from an earlier run whose PATH edit
# (to ~/.bashrc) only reaches future shells, not this one.
if ! command -v unity >/dev/null 2>&1
then
  if [ -x "${HOME}/.local/bin/unity" ]
  then
    PATH="${HOME}/.local/bin:${PATH}"
    export PATH
  else
    echo "Error: the unity CLI is not on PATH. Run ./setup once (without --dry-run) first so lib/unity.sh installs it." >&2
    exit 1
  fi
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

# Discovered empirically (#85): a freshly installed Editor
# (`-batchmode -nographics -quit`, no project) on a clean Ubuntu image
# carrying only the packages `lib/base-install.sh` already installs
# fails the dynamic linker before reaching Unity's own license check —
# `error while loading shared libraries: libgtk-3.so.0: cannot open
# shared object file: No such file or directory`. Installing the
# package below is the only apt dependency this repeatedly reproduced;
# once present, the Editor reaches "No valid Unity Editor license
# found" cleanly (both without any module and with `linux-il2cpp`
# installed), so no other library is missing.
#
# The package providing `libgtk-3.so.0` was renamed for the 64-bit
# `time_t` transition: `libgtk-3-0t64` on 24.04+, still `libgtk-3-0` on
# 22.04 and older (no transitional package bridges the two names, so a
# hardcoded single name breaks one release or the other).
resolve_apt_package() {
  # $1 = current (post-t64-rename) name, $2 = pre-rename name
  if apt-cache show "$1" >/dev/null 2>&1
  then
    printf '%s' "$1"
  elif apt-cache show "$2" >/dev/null 2>&1
  then
    printf '%s' "$2"
  else
    echo "Error: neither '$1' nor '$2' is a known apt package on this system (stale apt lists, or an unsupported Ubuntu release). Run 'sudo apt-get update' and retry, or file an issue if this release genuinely lacks both." >&2
    exit 1
  fi
}

# `unity install --dry-run --json` output is parsed with grep/sed instead
# of jq: this script can run before base-install.sh (a bare --unity
# --dry-run only needs the CLI, already required above), so jq is not
# guaranteed to be on PATH yet.
#
# Both helpers fail loudly with a targeted message when the field is
# missing/renamed, rather than a bare failed pipeline aborting the
# script under `set -e` with no explanation.
json_field() {
  value="$(printf '%s' "$1" | grep -o "\"$2\":[[:space:]]*\"[^\"]*\"" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')"
  if [ -z "$value" ]
  then
    echo "Error: could not find a \"$2\" string field in the unity CLI's JSON output. Its output format may have changed." >&2
    exit 1
  fi
  printf '%s' "$value"
}

json_number_field() {
  value="$(printf '%s' "$1" | grep -o "\"$2\":[[:space:]]*[0-9]*" | head -1 | grep -o '[0-9]*$' || true)"
  if [ -z "$value" ]
  then
    echo "Error: could not find a \"$2\" numeric field in the unity CLI's JSON output. Its output format may have changed." >&2
    exit 1
  fi
  printf '%s' "$value"
}

resolve() {
  # $1 = version selector, $2 = changeset (empty if none)
  # -m takes every module in one variadic flag (not one -m per module);
  # word-splitting $MODULES is intentional to pass them as separate
  # arguments to that one flag, since this script is POSIX sh and a bash
  # array is not available.
  if [ -n "$2" ]
  then
    # shellcheck disable=SC2086
    unity install "$1" -c "$2" --dry-run --non-interactive --yes --json -m $MODULES --cm
  else
    # shellcheck disable=SC2086
    unity install "$1" --dry-run --non-interactive --yes --json -m $MODULES --cm
  fi
}

# Prints yes or no for the alreadyInstalled flag of an exact-version
# dry-run. The CLI reports the flag for installed and missing Editors
# alike, so a missing or unreadable flag fails the run rather than
# reading as "not installed", which would start an install.
installed_state() {
  if printf '%s' "$1" | grep -Eq '"alreadyInstalled"[[:space:]]*:[[:space:]]*true'
  then
    printf 'yes'
  elif printf '%s' "$1" | grep -Eq '"alreadyInstalled"[[:space:]]*:[[:space:]]*false'
  then
    printf 'no'
  else
    echo "Error: could not read alreadyInstalled from the unity CLI's JSON output. Its output format may have changed." >&2
    exit 1
  fi
}

# Prints the ids, space-separated, of the modules the CLI would still add
# to an installed Editor, child modules included. Prints nothing when the
# set is complete. The dry-run answers "No modules found to install." in
# that case and otherwise answers with success and the ids to add. Its
# exit status differs between the two answers, so the text decides.
modules_to_add() {
  # $1 = exact version
  # shellcheck disable=SC2086
  probe="$(unity install-modules -e "$1" -m $MODULES --cm --dry-run --json --non-interactive 2>&1 || true)"
  # Only the errors array decides this: a warning may carry a message of its
  # own. The complete-set answer has exactly one error message, and the same
  # message next to another error is a failed probe, not a complete set.
  errors="$(printf '%s' "$probe" | tr '\n' ' ' | sed 's/.*"errors"//; s/"warnings".*//')"
  if printf '%s' "$errors" | grep -Eq '"message"[[:space:]]*:[[:space:]]*"No modules found to install\."' && [ "$(printf '%s' "$errors" | grep -o '"message"' | wc -l | tr -d ' ')" -eq 1 ]
  then
    return 0
  fi
  if ! printf '%s' "$probe" | grep -Eq '"success"[[:space:]]*:[[:space:]]*true'
  then
    echo "Error: could not read the module plan for Unity ${1}. Its output format may have changed." >&2
    exit 1
  fi
  # A success answer with no module ids is not a plan either: the set would
  # read as complete without anything having been checked.
  ids="$(printf '%s' "$probe" | grep -o '"id"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/' | tr '\n' ' ' | sed 's/ $//')"
  if [ -z "$ids" ]
  then
    echo "Error: the module plan for Unity ${1} lists no modules. Its output format may have changed." >&2
    exit 1
  fi
  printf '%s' "$ids"
}

# A tolerated answer counts only when the state it reports is confirmed here.
# The answer text alone is not trusted, because a failed call can print the
# expected message next to another error.
verify_editor_state() {
  # $1 = exact version, $2 = changeset (empty if none)
  if [ -n "$2" ]
  then
    state_json="$(resolve "$1" "$2")"
  else
    state_json="$(resolve "$1" "")"
  fi
  if [ "$(installed_state "$state_json")" != yes ]
  then
    echo "Error: Unity ${1} is not reported as installed, so the tolerated answer cannot be trusted. Stopping." >&2
    exit 1
  fi
}

verify_modules() {
  # $1 = exact version
  remaining="$(modules_to_add "$1")"
  if [ -n "$remaining" ]
  then
    echo "Error: Unity ${1} still lacks modules (${remaining}), so the tolerated answer cannot be trusted. Stopping." >&2
    exit 1
  fi
}

# Quotes one argument for the POSIX shell that `script -c` runs.
shell_quote() {
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

# Sends TERM to a process and all of its descendants. The wrapped call
# inherits SIGINT ignored, because it runs in the background, so TERM is the
# signal that stops it.
kill_tree() {
  for child_pid in $(ps -o pid= --ppid "$1" 2>/dev/null)
  do
    kill_tree "$child_pid"
  done
  kill -TERM "$1" 2>/dev/null || true
}

# Runs one mutating unity command under a pseudo-terminal, so the CLI draws
# its progress as it would on a terminal. Output streams to the terminal as
# it arrives and is also kept, so the outcome can be matched on its text. A
# non-zero status counts as success only when the output carries the one
# message this call expects. That message means the requested state already
# holds. Any other failure exits the script with the CLI's own status.
run_unity() {
  # $1 = the message that counts as success for this call, $2... = unity arguments
  expected="$1"
  shift
  # The CLI status is written by the wrapped command itself, so a failure of
  # `script` is never read as a CLI status. The files are cleared first, so a
  # record left by an earlier call cannot be read here.
  rm -f "${run_dir}/status" "${run_dir}/script.pid"
  command_line="unity"
  for arg in "$@"
  do
    command_line="${command_line} $(shell_quote "$arg")"
  done
  # `script -c` runs its string under $SHELL, so SHELL is pinned to /bin/sh.
  # The call runs in the background so that the trap below can act while it
  # runs: a trap waits for a foreground child to exit. The pipeline itself is
  # backgrounded and waited on, so `$!` names a process this shell can signal.
  (
    SHELL=/bin/sh script -q -e -f -c "${command_line}; printf '%s\\n' \$? > $(shell_quote "${run_dir}/status")" /dev/null &
    echo "$!" > "${run_dir}/script.pid"
    wait "$!"
  ) | tee "${run_dir}/output" &
  run_pipe=$!
  wait "$run_pipe" 2>/dev/null || true
  status=""
  if [ -f "${run_dir}/status" ]
  then
    status="$(cat "${run_dir}/status")"
  fi
  case "$status" in
    ''|*[!0-9]*)
      echo "Error: script did not record the unity status for '$1'. Check that script(1) can run a pseudo-terminal here." >&2
      exit 1
      ;;
  esac
  last_outcome=ok
  if [ "$status" -eq 0 ]
  then
    return 0
  fi
  if tr -d '\r' < "${run_dir}/output" | grep -qF -- "$expected"
  then
    last_outcome=tolerated
    return 0
  fi
  echo "Error: unity $1 failed with exit status ${status}." >&2
  exit "$status"
}

# Ctrl-C reaches this shell. The wrapped call runs in the background, so it
# is stopped here by TERM to its whole process tree, and the script exits 130.
stop_unity_call() {
  if [ -f "${run_dir}/script.pid" ]
  then
    kill_tree "$(cat "${run_dir}/script.pid")"
  fi
  exit 130
}

# The re-run checks match the CLI's English result messages, so they need the
# CLI display language set to English. Called only when an Editor is already
# installed, because only a re-run depends on those messages.
require_english_cli() {
  if ! lang_json="$(unity language --format json 2>&1)"
  then
    echo "Error: could not read the Unity CLI display language: ${lang_json}" >&2
    exit 1
  fi
  if ! printf '%s' "$lang_json" | grep -Eq '"current"[[:space:]]*:[[:space:]]*"en"'
  then
    echo "Error: the Unity CLI display language is not English. The re-run checks read its English result messages, so run 'unity language --set en' and retry." >&2
    exit 1
  fi
}

# Prints the plan line for one resolved Editor. An installed Editor lists
# only the modules still to add. A missing one lists every required module
# the install would add, with its download size.
describe_editor() {
  # $1 = label, $2 = exact version, $3 = installed (yes|no), $4 = download size in bytes
  if [ "$3" = yes ]
  then
    missing="$(modules_to_add "$2")"
    if [ -z "$missing" ]
    then
      plan "${1}: ${2} already installed; required modules present"
    else
      plan "${1}: ${2} already installed; modules to add: ${missing}"
    fi
  else
    plan "${1}: ${2} would be installed with modules ${MODULES} (--cm), ~$(($4 / 1024 / 1024 / 1024)) GiB download"
  fi
}

# Brings one resolved Editor to the required state. An installed Editor
# only gets its missing modules added. An Editor that is not installed is
# installed with the full module set. The exact version is installed, not
# the selector: re-passing the selector here could resolve to a different
# (newer) release if one shipped between the resolve call and this one.
# install-modules gets the same non-interactive flags as install: a prompt
# on a headless host would hang, and --accept-eula covers module licences.
converge_editor() {
  # $1 = label, $2 = exact version, $3 = changeset (empty if none), $4 = installed (yes|no)
  if [ "$4" = no ]
  then
    log "installing ${1} ${2}..."
    if [ -n "$3" ]
    then
      # shellcheck disable=SC2086
      run_unity "Editor already installed in this location." install "$2" -c "$3" --non-interactive --yes --accept-eula -m $MODULES --cm
    else
      # shellcheck disable=SC2086
      run_unity "Editor already installed in this location." install "$2" --non-interactive --yes --accept-eula -m $MODULES --cm
    fi
    if [ "$last_outcome" = ok ]
    then
      return 0
    fi
    # The CLI reports the Editor as present after all. Confirm that before its modules are touched.
    log "${1} ${2} was already present; confirming it..."
    verify_editor_state "$2" "$3"
  fi

  log "adding any missing modules to ${1} ${2}..."
  # shellcheck disable=SC2086
  run_unity "No modules found to install." install-modules -e "$2" -m $MODULES --cm --non-interactive --yes --accept-eula
  verify_modules "$2"
}

# Holds the output and exit status of each mutating unity call (see run_unity).
run_dir="$(mktemp -d)"
trap 'rm -rf "$run_dir"' EXIT
# Ctrl-C stops the wrapped unity call through stop_unity_call, which exits 130.
# The EXIT trap above still runs and removes the scratch directory.
trap stop_unity_call INT

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

# Installed state comes from each exact version's own dry-run, so an older
# 6000.3.* patch that is already on disk never satisfies the resolved one.
# The general-games selector only resolves the version, so it needs its
# own exact-version dry-run. The VRChat selector above already is one.
general_exact_json="$(resolve "$general_version" "")"
general_installed="$(installed_state "$general_exact_json")"
vrchat_installed="$(installed_state "$vrchat_json")"

if [ "$general_installed" = yes ] || [ "$vrchat_installed" = yes ]
then
  require_english_cli
fi

if [ "$DRY_RUN" -eq 1 ]
then
  describe_editor "general games" "$general_version" "$general_installed" "$general_size"
  describe_editor "VRChat (changeset ${VRCHAT_CHANGESET})" "$vrchat_version" "$vrchat_installed" "$vrchat_size"
  if [ "$general_installed" = no ] || [ "$vrchat_installed" = no ]
  then
    plan "estimated disk required: ${REQUIRED_DISK_GIB} GiB"
  fi
  exit 0
fi

# Every real run calls the CLI under a pseudo-terminal through script(1). The
# check runs before the apt step and before any mutating call. There is no
# fallback to a plain pipe, because a pipe changes how the CLI draws progress.
if ! command -v script >/dev/null 2>&1
then
  echo "Error: script(1) from util-linux is required to run the Unity CLI under a pseudo-terminal. Install util-linux and run again." >&2
  exit 1
fi

# The disk preflight guards an Editor download, so it applies only when at
# least one Editor is still to be installed. Modules alone do not trigger it.
if [ "$general_installed" = no ] || [ "$vrchat_installed" = no ]
then
  # Check space on the CLI's actual configured Editor install path, not
  # assumed to be under $HOME: `unity install-path --set` can point it
  # elsewhere. Walk up to the nearest existing ancestor first, since the
  # target directory itself may not exist yet on a first install and df
  # requires a real path.
  disk_check_path="$(unity install-path)"
  while [ ! -d "$disk_check_path" ]
  do
    disk_check_path="$(dirname "$disk_check_path")"
  done

  avail_kib="$(df -Pk "$disk_check_path" | awk 'NR==2 {print $4}')"
  avail_gib=$((avail_kib / 1024 / 1024))
  if [ "$avail_gib" -lt "$REQUIRED_DISK_GIB" ]
  then
    echo "Error: --unity needs ~${REQUIRED_DISK_GIB} GiB free at ${disk_check_path}, but only ${avail_gib} GiB is available." >&2
    exit 1
  fi
fi

# Runs only after the disk preflight above passes, so a run that fails
# that check leaves no partial apt-level system change behind. It runs on
# every real run, including when both Editors are already installed.
unity_apt_package="$(resolve_apt_package libgtk-3-0t64 libgtk-3-0)"
log "installing Editor runtime dependency (${unity_apt_package})..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install \
  --no-install-recommends -y -qq "$unity_apt_package"

converge_editor "general games" "$general_version" "" "$general_installed"
converge_editor "VRChat" "$vrchat_version" "$VRCHAT_CHANGESET" "$vrchat_installed"

log "done."
