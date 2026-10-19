#!/bin/sh
# -*- mode: sh -*-
# vim: set ft=sh :

# Re-run tests for lib/unity-editors.sh. The unity CLI, sudo, apt-cache, and
# df are stubbed on PATH, so no Editor is downloaded and nothing is installed.
# Each case sets the installed state the stubs report, runs the script, and
# checks the exit status, the output, and the calls the script made.

set -eu
cd "$(cd "$(dirname "$0")/.."; pwd)"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# The real script(1), resolved before the stub directory goes first on PATH.
STUB_REAL_SCRIPT="$(command -v script || true)"
export STUB_REAL_SCRIPT

STUB_BIN="${WORK}/bin"
STUB_LOG="${WORK}/calls.log"
STUB_INSTALL_ROOT="${WORK}/editors"
mkdir -p "$STUB_BIN" "$STUB_INSTALL_ROOT"
PATH="${STUB_BIN}:${PATH}"
export PATH STUB_LOG STUB_INSTALL_ROOT

write_stub() {
  cat > "${STUB_BIN}/$1"
  chmod +x "${STUB_BIN}/$1"
}

# Every stub appends its argv to $STUB_LOG and answers from the STUB_*
# variables that begin_case sets.
write_stub unity <<'STUB'
#!/bin/sh
printf 'unity %s\n' "$*" >> "$STUB_LOG"

# Matches a whole space-separated word in a list.
has_word() {
  case " $2 " in
    *" $1 "*) return 0 ;;
  esac
  return 1
}

# An Editor counts as installed when the case lists it or an install marker
# exists. The markers let a tolerated answer's claim show up in later calls.
is_installed() {
  has_word "$1" "$STUB_INSTALLED" || [ -f "$STUB_INSTALL_ROOT/installed-$1" ]
}

# The 6.3 selector resolves to the patch the case configures.
exact_version() {
  if [ "$1" = "6.3" ]
  then
    printf '%s' "$STUB_GENERAL_RESOLVED"
  else
    printf '%s' "$1"
  fi
}

case "$1" in
  install-path)
    printf '%s\n' "$STUB_INSTALL_ROOT"
    ;;
  install)
    version="$(exact_version "$2")"
    case " $* " in
      *" --dry-run "*)
        already=false
        if is_installed "$version"
        then
          already=true
        fi
        # The 6.3 selector call omits the flag on purpose. The real CLI reports
        # it there too, so this is a deliberate deviation: it makes sure the
        # script reads installed state from the exact-version dry-run only.
        if [ -n "${STUB_NO_FLAG:-}" ] || [ "$2" = 6.3 ]
        then
          printf '{"data": {"version": "%s", "totalDownloadSize": 13958643712}}\n' "$version"
        else
          printf '{"data": {"version": "%s", "totalDownloadSize": 13958643712, "alreadyInstalled": %s}}\n' "$version" "$already"
        fi
        ;;
      *)
        case "${STUB_MUTATING:-ok}" in
          already)
            # Reports the Editor present, and it is present from now on.
            touch "$STUB_INSTALL_ROOT/installed-$version"
            printf '{"code":"COMMAND_FAILED","message":"Editor already installed in this location."}\n'
            exit 6
            ;;
          second-fail)
            # The expected message next to a second error, and no state change.
            echo "Editor already installed in this location."
            echo "Error: simulated second failure" >&2
            exit 6
            ;;
          second-ok)
            # The expected message next to a second error, with the state holding.
            touch "$STUB_INSTALL_ROOT/installed-$version"
            echo "Editor already installed in this location."
            echo "Error: simulated second failure" >&2
            exit 6
            ;;
          fail)
            echo "Error: simulated install failure" >&2
            exit 1
            ;;
          nomodules)
            echo "No modules found to install."
            exit 6
            ;;
          exit3)
            echo "simulated failure without the expected message" >&2
            exit 3
            ;;
        esac
        # Prints a progress line only on a terminal, as the real CLI does.
        if [ -n "${STUB_PROGRESS:-}" ] && [ -t 1 ]
        then
          printf 'progress 50%%\n'
        fi
        # Stands in for a long download: records its pid and a child's pid,
        # then waits, so the interrupt case can stop it.
        if [ -n "${STUB_BLOCK_DIR:-}" ]
        then
          echo "$$" > "$STUB_BLOCK_DIR/stub.pid"
          sleep 60 &
          echo "$!" > "$STUB_BLOCK_DIR/child.pid"
          wait
        fi
        touch "$STUB_INSTALL_ROOT/installed-$version"
        echo "installed ${version}"
        ;;
    esac
    ;;
  install-modules)
    version="$3"
    case " $* " in
      *" --dry-run "*)
        # Mirrors the real dry-run: "No modules found" with exit 6 when the
        # set is complete, otherwise success with the ids still to add.
        if [ "${STUB_PROBE:-}" = garbage ]
        then
          echo "unexpected output"
          exit 1
        fi
        if [ "${STUB_PROBE:-}" = emptyplan ]
        then
          printf '{"success": true, "command": "install-modules", "data": {"modules": []}}\n'
          exit 0
        fi
        if [ "${STUB_PROBE:-}" = twoerrors ]
        then
          printf '{"success": false, "command": "install-modules", "data": null, "errors": [{"code": "COMMAND_FAILED", "message": "No modules found to install."}, {"code": "COMMAND_FAILED", "message": "Other failure."}], "warnings": []}\n'
          exit 6
        fi
        if [ "${STUB_PROBE:-}" = warnmsg ]
        then
          # A complete set whose warnings also carry a message.
          printf '{"success": false, "command": "install-modules", "data": null, "errors": [{"code": "COMMAND_FAILED", "message": "No modules found to install."}], "warnings": [{"code": "NOTE", "message": "Something else."}]}\n'
          exit 6
        fi
        if [ -z "${STUB_MISSING:-}" ] || [ -f "$STUB_INSTALL_ROOT/modules-$version" ]
        then
          printf '{"success": false, "command": "install-modules", "data": null, "errors": [{"code": "COMMAND_FAILED", "message": "No modules found to install."}], "warnings": []}\n'
          exit 6
        fi
        echo "Adding module cmake-3.22.1 as dependency of android-sdk-ndk-tools."
        printf '{"success": true, "command": "install-modules", "data": {"modules": ['
        for module in $STUB_MISSING
        do
          printf '{"id": "%s", "downloadSize": 1}, ' "$module"
        done
        if has_word android "$STUB_MISSING"
        then
          printf '{"id": "cmake-3.22.1", "downloadSize": 1}, '
        fi
        printf ']}}\n'
        exit 0
        ;;
    esac
    if [ "${STUB_MODULES:-ok}" = fail ]
    then
      echo "Error: simulated module failure" >&2
      exit 1
    fi
    if [ "${STUB_MODULES:-ok}" = already ]
    then
      printf '{"code":"COMMAND_FAILED","message":"Editor already installed in this location."}\n'
      exit 6
    fi
    if [ "${STUB_MODULES:-ok}" = lie ]
    then
      # Says nothing is left, while modules are still missing and nothing was added.
      echo "No modules found to install."
      exit 6
    fi
    if [ -z "${STUB_MISSING:-}" ] || [ -f "$STUB_INSTALL_ROOT/modules-$version" ]
    then
      echo "No modules found to install."
      exit 6
    fi
    touch "$STUB_INSTALL_ROOT/modules-$version"
    echo "installed modules: ${STUB_MISSING}"
    ;;
  language)
    if [ -n "${STUB_LANG_FAIL:-}" ]
    then
      echo "Error: simulated language failure" >&2
      exit 1
    fi
    printf '{"success": true, "command": "language", "data": {"current": "%s", "name": "x"}}\n' "${STUB_LANG:-en}"
    exit 0
    ;;
  *)
    echo "stub: unexpected unity subcommand: $1" >&2
    exit 2
    ;;
esac
STUB

write_stub sudo <<'STUB'
#!/bin/sh
printf 'sudo %s\n' "$*" >> "$STUB_LOG"
# Drop the NAME=value assignments that precede the command, then run it.
while [ "$#" -gt 0 ]
do
  case "$1" in
    *=*) shift ;;
    *) break ;;
  esac
done
"$@"
STUB

write_stub apt-get <<'STUB'
#!/bin/sh
printf 'apt-get %s\n' "$*" >> "$STUB_LOG"
STUB

write_stub apt-cache <<'STUB'
#!/bin/sh
printf 'apt-cache %s\n' "$*" >> "$STUB_LOG"
if [ "$1" = pkgnames ]
then
  # Lists the ICU package names that apt would know, one per line.
  for name in ${STUB_ICU_PACKAGES:-}
  do
    printf '%s\n' "$name"
  done
  exit 0
fi
[ "$2" = "libgtk-3-0t64" ]
STUB

write_stub df <<'STUB'
#!/bin/sh
printf 'df %s\n' "$*" >> "$STUB_LOG"
printf 'Filesystem 1024-blocks Used Available Capacity Mounted on\n'
printf 'stub 1 1 %s 1%% /\n' "$((STUB_DF_GIB * 1024 * 1024))"
STUB

FAILURES=0
CASE=""
CASE_OK=1
STATUS=0
OUTPUT=""

# Resets the stub state to a neutral default: no Editor installed, 100 GiB
# free, every mutating call succeeding. A case overrides what it needs.
begin_case() {
  CASE="$1"
  CASE_OK=1
  : > "$STUB_LOG"
  rm -f "$STUB_INSTALL_ROOT"/installed-* "$STUB_INSTALL_ROOT"/modules-*
  export STUB_INSTALLED="" STUB_GENERAL_RESOLVED="6000.3.10f1"
  export STUB_MISSING="" STUB_PROBE="" STUB_NO_FLAG="" STUB_LANG="en" STUB_LANG_FAIL="" STUB_MUTATING="ok" STUB_MODULES="ok" STUB_DF_GIB="100"
  export STUB_ICU_PACKAGES="libicu78"
}

# Runs the script with the given arguments and keeps its status and output.
run_script() {
  set +e
  OUTPUT="$(sh lib/unity-editors.sh "$@" 2>&1)"
  STATUS=$?
  set -e
}

fail_check() {
  printf 'FAIL: %s: %s\n' "$CASE" "$1" >&2
  CASE_OK=0
}

expect_status() {
  if [ "$STATUS" -ne "$1" ]
  then
    fail_check "expected exit $1, got ${STATUS}"
  fi
}

expect_output() {
  if ! printf '%s\n' "$OUTPUT" | grep -qF -- "$1"
  then
    fail_check "expected output to contain: $1"
  fi
}

expect_no_output() {
  if printf '%s\n' "$OUTPUT" | grep -qF -- "$1"
  then
    fail_check "output should not contain: $1"
  fi
}

expect_call() {
  if ! grep -qF -- "$1" "$STUB_LOG"
  then
    fail_check "expected a call containing: $1"
  fi
}

expect_no_call() {
  if grep -qF -- "$1" "$STUB_LOG"
  then
    fail_check "unexpected call containing: $1"
  fi
}

# A mutating `unity install` is any install call without --dry-run.
expect_no_mutating_install() {
  if grep -E '^unity install ' "$STUB_LOG" | grep -qv -- '--dry-run'
  then
    fail_check "unexpected mutating unity install"
  fi
}

expect_no_mutating_modules() {
  if grep -E '^unity install-modules ' "$STUB_LOG" | grep -qv -- '--dry-run'
  then
    fail_check "unexpected mutating unity install-modules"
  fi
}

expect_no_mutating_install_of() {
  if grep -E "^unity install $1 " "$STUB_LOG" | grep -qv -- '--dry-run'
  then
    fail_check "unexpected mutating unity install of $1"
  fi
}

finish_case() {
  # Holds for every case: the script never forces, reinstalls, or uninstalls.
  if grep -qE -- '--reinstall|--force|uninstall' "$STUB_LOG"
  then
    fail_check "unexpected --reinstall, --force, or uninstall call"
  fi
  if [ "$CASE_OK" -eq 1 ]
  then
    printf 'PASS: %s\n' "$CASE"
  else
    FAILURES=$((FAILURES + 1))
  fi
}

GENERAL_INSTALL="unity install 6000.3.10f1 --non-interactive --yes --accept-eula -m android linux-il2cpp windows-mono --cm"
VRCHAT_INSTALL="unity install 2022.3.22f1 -c 887be4894c44 --non-interactive --yes --accept-eula -m android linux-il2cpp windows-mono --cm"
GENERAL_MODULES="unity install-modules -e 6000.3.10f1 -m android linux-il2cpp windows-mono --cm --non-interactive --yes --accept-eula"
VRCHAT_MODULES="unity install-modules -e 2022.3.22f1 -m android linux-il2cpp windows-mono --cm --non-interactive --yes --accept-eula"
GENERAL_PROBE="unity install-modules -e 6000.3.10f1 -m android linux-il2cpp windows-mono --cm --dry-run --json --non-interactive"
APT_CALL="sudo DEBIAN_FRONTEND=noninteractive apt-get install"

begin_case "both installed, low disk: no gate, apt runs, modules checked"
STUB_INSTALLED="6000.3.10f1 2022.3.22f1"
STUB_DF_GIB=10
run_script
expect_status 0
expect_output "No modules found to install."
expect_output "done."
expect_no_mutating_install
expect_no_call "df -Pk"
expect_call "$GENERAL_MODULES"
expect_call "$VRCHAT_MODULES"
expect_call "$APT_CALL"
expect_no_call "--reinstall"
expect_no_call "--force"
finish_case

begin_case "only general installed: VRChat installed, general left alone"
STUB_INSTALLED="6000.3.10f1"
STUB_DF_GIB=40
run_script
expect_status 0
expect_call "$VRCHAT_INSTALL"
expect_no_mutating_install_of 6000.3.10f1
expect_call "$GENERAL_MODULES"
expect_no_call "unity install-modules -e 2022.3.22f1"
expect_call "df -Pk"
expect_call "$APT_CALL"
finish_case

begin_case "one Editor present, 20 GiB free: fails before apt and install"
STUB_INSTALLED="6000.3.10f1"
STUB_DF_GIB=20
run_script
expect_status 1
expect_output "needs ~30 GiB free"
expect_output "only 20 GiB is available"
expect_no_call "sudo"
expect_no_mutating_install
finish_case

begin_case "neither installed, 40 GiB free: both installed, apt runs"
STUB_DF_GIB=40
run_script
expect_status 0
expect_call "$GENERAL_INSTALL"
expect_call "$VRCHAT_INSTALL"
expect_call "$APT_CALL"
expect_no_call "unity install-modules"
finish_case

begin_case "neither installed, 10 GiB free: fails before apt and install"
STUB_DF_GIB=10
run_script
expect_status 1
expect_output "needs ~30 GiB free"
expect_output "only 10 GiB is available"
expect_no_call "sudo"
expect_no_mutating_install
finish_case

begin_case "both installed, one module missing, low disk: modules added, no gate"
STUB_INSTALLED="6000.3.10f1 2022.3.22f1"
STUB_MISSING="windows-mono"
STUB_DF_GIB=10
run_script
expect_status 0
expect_output "installed modules: windows-mono"
expect_call "$GENERAL_MODULES"
expect_no_call "df -Pk"
expect_no_mutating_install
expect_no_call "--reinstall"
expect_no_call "--force"
finish_case

begin_case "general installed missing a module, VRChat missing: both handled"
STUB_INSTALLED="6000.3.10f1"
STUB_MISSING="windows-mono"
STUB_DF_GIB=40
run_script
expect_status 0
expect_call "$GENERAL_MODULES"
expect_call "$VRCHAT_INSTALL"
expect_no_mutating_install_of 6000.3.10f1
finish_case

begin_case "mutating install fails: exits non-zero, later steps skipped"
STUB_MUTATING=fail
STUB_DF_GIB=40
run_script
expect_status 1
expect_output "failed with exit status 1"
expect_no_mutating_install_of 2022.3.22f1
expect_no_call "install-modules"
finish_case

begin_case "install reports already installed: tolerated, modules still checked"
STUB_MUTATING=already
STUB_DF_GIB=40
run_script
expect_status 0
expect_output "Editor already installed in this location."
expect_call "$GENERAL_MODULES"
expect_call "$VRCHAT_MODULES"
finish_case

begin_case "install-modules fails: exits non-zero"
STUB_INSTALLED="6000.3.10f1 2022.3.22f1"
STUB_MISSING="windows-mono"
STUB_MODULES=fail
STUB_DF_GIB=100
run_script
expect_status 1
expect_output "failed with exit status 1"
finish_case

begin_case "newer 6000.3 patch: resolved patch installed, older patch kept"
STUB_INSTALLED="6000.3.9f1 2022.3.22f1"
STUB_GENERAL_RESOLVED="6000.3.10f1"
STUB_DF_GIB=40
run_script
expect_status 0
expect_call "$GENERAL_INSTALL"
expect_no_call "unity install 6000.3.9f1"
expect_no_call "uninstall"
expect_no_mutating_install_of 2022.3.22f1
expect_call "$VRCHAT_MODULES"
finish_case

begin_case "dry-run, both installed: plan says so, no disk line, nothing mutated"
STUB_INSTALLED="6000.3.10f1 2022.3.22f1"
STUB_DF_GIB=10
run_script --dry-run
expect_status 0
expect_output "general games: 6000.3.10f1 already installed; required modules present"
expect_output "VRChat (changeset 887be4894c44): 2022.3.22f1 already installed; required modules present"
expect_no_output "estimated disk required"
expect_no_mutating_install
expect_no_mutating_modules
expect_call "$GENERAL_PROBE"
expect_no_call "df -Pk"
expect_no_call "sudo"
finish_case

begin_case "dry-run, installed Editor missing a module: names the module"
STUB_INSTALLED="6000.3.10f1 2022.3.22f1"
STUB_MISSING="windows-mono"
run_script --dry-run
expect_status 0
expect_output "general games: 6000.3.10f1 already installed; modules to add: windows-mono"
expect_no_output "estimated disk required"
expect_no_mutating_install
expect_no_mutating_modules
finish_case

begin_case "dry-run, only general installed: disk line still shown"
STUB_INSTALLED="6000.3.10f1"
run_script --dry-run
expect_status 0
expect_output "general games: 6000.3.10f1 already installed; required modules present"
expect_output "VRChat (changeset 887be4894c44): 2022.3.22f1 would be installed"
expect_output "estimated disk required: 30 GiB"
expect_no_mutating_install
finish_case

begin_case "dry-run, module child named by the CLI: android adds cmake too"
STUB_INSTALLED="6000.3.10f1 2022.3.22f1"
STUB_MISSING="android"
run_script --dry-run
expect_status 0
expect_output "modules to add: android cmake-3.22.1"
expect_no_mutating_modules
finish_case

begin_case "dry-run, neither installed: download sizes and disk requirement shown"
run_script --dry-run
expect_status 0
expect_output "general games: 6000.3.10f1 would be installed with modules android linux-il2cpp windows-mono (--cm), ~13 GiB download"
expect_output "estimated disk required: 30 GiB"
expect_no_mutating_install
expect_no_call "df -Pk"
finish_case

begin_case "dry-run, unreadable module plan: fails instead of reading as present"
STUB_INSTALLED="6000.3.10f1 2022.3.22f1"
STUB_PROBE=garbage
run_script --dry-run
expect_status 1
expect_output "could not read the module plan for Unity 6000.3.10f1"
finish_case

begin_case "alreadyInstalled missing from the dry-run JSON: fails before the disk gate"
STUB_NO_FLAG=1
STUB_DF_GIB=10
run_script
expect_status 1
expect_output "could not read alreadyInstalled"
expect_no_call "df -Pk"
expect_no_call "sudo"
expect_no_mutating_install
finish_case

begin_case "only VRChat installed, 40 GiB free: general installed now, VRChat modules repaired"
STUB_INSTALLED="2022.3.22f1"
STUB_DF_GIB=40
run_script
expect_status 0
expect_call "$GENERAL_INSTALL"
expect_no_mutating_install_of 2022.3.22f1
expect_call "$VRCHAT_MODULES"
expect_call "$APT_CALL"
finish_case

begin_case "neither installed, exactly 30 GiB free: the gate passes"
STUB_DF_GIB=30
run_script
expect_status 0
expect_call "$APT_CALL"
finish_case

begin_case "dry-run, only VRChat installed: general plan names its modules"
STUB_INSTALLED="2022.3.22f1"
run_script --dry-run
expect_status 0
expect_output "general games: 6000.3.10f1 would be installed with modules android linux-il2cpp windows-mono (--cm), ~13 GiB download"
expect_output "VRChat (changeset 887be4894c44): 2022.3.22f1 already installed; required modules present"
expect_output "estimated disk required: 30 GiB"
expect_no_mutating_install
finish_case

begin_case "install already present, module still missing: module added"
STUB_MUTATING=already
STUB_MISSING="windows-mono"
STUB_DF_GIB=40
run_script
expect_status 0
expect_output "installed modules: windows-mono"
expect_call "$GENERAL_MODULES"
expect_call "$VRCHAT_MODULES"
finish_case

begin_case "install reports no modules: not tolerated, exits non-zero"
STUB_MUTATING=nomodules
STUB_DF_GIB=40
run_script
expect_status 6
expect_output "failed with exit status 6"
expect_no_call "install-modules"
expect_no_mutating_install_of 2022.3.22f1
finish_case

begin_case "install-modules reports already installed: not tolerated, exits non-zero"
STUB_INSTALLED="6000.3.10f1 2022.3.22f1"
STUB_MISSING="windows-mono"
STUB_MODULES=already
STUB_DF_GIB=100
run_script
expect_status 6
expect_output "failed with exit status 6"
finish_case

begin_case "installed Editor, CLI language not English: stops before any change"
STUB_INSTALLED="6000.3.10f1"
STUB_LANG=ja_jp
STUB_DF_GIB=100
run_script
expect_status 1
expect_output "display language is not English"
expect_no_call "sudo"
expect_no_mutating_install
expect_no_mutating_modules
finish_case

begin_case "dry-run, installed Editor, CLI language not English: stops"
STUB_INSTALLED="6000.3.10f1"
STUB_LANG=ja_jp
run_script --dry-run
expect_status 1
expect_output "display language is not English"
expect_no_output "already installed"
finish_case

begin_case "installed Editor, CLI language unreadable: fails before any change"
STUB_INSTALLED="6000.3.10f1"
STUB_LANG_FAIL=1
STUB_DF_GIB=100
run_script
expect_status 1
expect_output "could not read the Unity CLI display language"
expect_no_call "sudo"
expect_no_mutating_install
finish_case

begin_case "fresh install, CLI language not English: no English check needed"
STUB_LANG=ja_jp
STUB_DF_GIB=40
run_script
expect_status 0
expect_call "$GENERAL_INSTALL"
expect_call "$VRCHAT_INSTALL"
finish_case

begin_case "success plan with no module ids: fails instead of reading as complete"
STUB_INSTALLED="6000.3.10f1 2022.3.22f1"
STUB_PROBE=emptyplan
run_script --dry-run
expect_status 1
expect_output "lists no modules"
expect_no_output "required modules present"
expect_no_mutating_modules
finish_case

begin_case "module plan with two errors: fails instead of reading as complete"
STUB_INSTALLED="6000.3.10f1 2022.3.22f1"
STUB_PROBE=twoerrors
run_script --dry-run
expect_status 1
expect_output "could not read the module plan for Unity 6000.3.10f1"
expect_no_mutating_modules
finish_case

begin_case "dry-run, complete set with a warning message: still complete"
STUB_INSTALLED="6000.3.10f1 2022.3.22f1"
STUB_PROBE=warnmsg
run_script --dry-run
expect_status 0
expect_output "general games: 6000.3.10f1 already installed; required modules present"
finish_case

begin_case "install-modules says nothing is left while modules are missing: not trusted"
STUB_INSTALLED="6000.3.10f1 2022.3.22f1"
STUB_MISSING="windows-mono"
STUB_MODULES=lie
STUB_DF_GIB=100
run_script
expect_status 1
expect_output "still lacks modules"
finish_case

begin_case "install prints the expected message with a second error and no state change: not trusted"
STUB_MUTATING=second-fail
STUB_DF_GIB=40
run_script
expect_status 1
expect_output "cannot be trusted"
expect_no_call "install-modules"
finish_case

begin_case "install prints the expected message with a second error and the state holds: accepted"
STUB_MUTATING=second-ok
STUB_DF_GIB=40
run_script
expect_status 0
expect_output "Error: simulated second failure"
expect_call "$GENERAL_MODULES"
finish_case

# True while a process runs. A zombie (defunct) process still answers kill -0,
# so its state is checked as well.
process_alive() {
  kill -0 "$1" 2>/dev/null || return 1
  case "$(ps -o stat= -p "$1" 2>/dev/null)" in
    ''|Z*) return 1 ;;
    *) return 0 ;;
  esac
}

# A PATH with every system tool except script(1), for the missing-script cases.
make_noscript_bin() {
  NOSCRIPT_BIN="${WORK}/noscript"
  mkdir -p "$NOSCRIPT_BIN"
  for dir in /usr/bin /bin
  do
    for file in "$dir"/*
    do
      name="$(basename "$file")"
      if [ "$name" != script ] && [ -x "$file" ] && [ ! -e "$NOSCRIPT_BIN/$name" ]
      then
        ln -s "$file" "$NOSCRIPT_BIN/$name"
      fi
    done
  done
}

begin_case "progress line reaches the captured output, with no script banner"
export LC_ALL=C STUB_PROGRESS=1
run_script
unset LC_ALL STUB_PROGRESS
expect_status 0
expect_output "progress 50%"
expect_no_output "Script started"
expect_no_output "Script done"
expect_call "$GENERAL_INSTALL"
finish_case

begin_case "a mutating call that fails without the expected message exits with its status"
STUB_MUTATING=exit3
run_script
expect_status 3
expect_output "simulated failure without the expected message"
expect_no_call "install-modules"
finish_case

begin_case "the caller's SHELL does not change the wrapped call"
OLD_SHELL="${SHELL-}"
SHELL_WAS_SET="${SHELL+x}"
export SHELL=/usr/bin/false
run_script
if [ -n "$SHELL_WAS_SET" ]
then
  export SHELL="$OLD_SHELL"
else
  unset SHELL
fi
expect_status 0
expect_call "$GENERAL_INSTALL"
finish_case

begin_case "no script(1) on PATH: exits before apt and before any mutating call"
make_noscript_bin
OLD_PATH="$PATH"
PATH="${STUB_BIN}:${NOSCRIPT_BIN}"
export PATH
run_script
PATH="$OLD_PATH"
export PATH
expect_status 1
expect_output "script(1)"
expect_no_call "apt-get"
expect_no_mutating_install
expect_no_mutating_modules
finish_case

begin_case "no script(1) on PATH: a dry run still succeeds"
make_noscript_bin
OLD_PATH="$PATH"
PATH="${STUB_BIN}:${NOSCRIPT_BIN}"
export PATH
run_script --dry-run
PATH="$OLD_PATH"
export PATH
expect_status 0
expect_output "[unity:plan]"
expect_no_mutating_install
finish_case

begin_case "script(1) present but failing: names script, not the CLI"
write_stub script <<'STUB'
#!/bin/sh
echo "pty allocation failed: no pseudo-terminal" >&2
exit 1
STUB
run_script
rm -f "${STUB_BIN}/script"
expect_status 1
expect_output "script did not record the unity status"
expect_no_output "failed with exit status"
expect_no_mutating_install
finish_case

begin_case "script(1) fails on the second call: names script, not the CLI"
write_stub script <<'STUB'
#!/bin/sh
count_file="$STUB_INSTALL_ROOT/script-calls"
n=$(cat "$count_file" 2>/dev/null || echo 0)
n=$((n + 1))
echo "$n" > "$count_file"
if [ "$n" -ge 2 ]
then
  echo "pty allocation failed: no pseudo-terminal" >&2
  exit 1
fi
exec "$STUB_REAL_SCRIPT" "$@"
STUB
run_script
rm -f "${STUB_BIN}/script" "$STUB_INSTALL_ROOT/script-calls"
expect_status 1
expect_output "script did not record the unity status"
expect_no_output "failed with exit status"
expect_call "$GENERAL_INSTALL"
finish_case

begin_case "SIGINT stops the wrapped call and its children, then exits 130"
BLOCK_DIR="${WORK}/block"
TMP_EMPTY="${WORK}/tmp-empty"
mkdir -p "$BLOCK_DIR" "$TMP_EMPTY"
export STUB_BLOCK_DIR="$BLOCK_DIR" TMPDIR="$TMP_EMPTY"
# SIGINT is reset to its default here, so the launched shell can receive it.
perl -e '$SIG{INT} = "DEFAULT"; exec @ARGV' sh lib/unity-editors.sh > "${WORK}/interrupt.out" 2>&1 &
SCRIPT_PID=$!
unset STUB_BLOCK_DIR TMPDIR
i=0
while [ ! -s "$BLOCK_DIR/child.pid" ] && [ "$i" -lt 100 ]
do
  sleep 0.1
  i=$((i + 1))
done
sigign="$(awk '/^SigIgn:/ {print $2}' "/proc/${SCRIPT_PID}/status" 2>/dev/null || true)"
case "$sigign" in
  *[2367abef]) fail_check "SIGINT is ignored in the script before the signal" ;;
esac
kill -INT "$SCRIPT_PID" 2>/dev/null || true
i=0
while process_alive "$SCRIPT_PID" && [ "$i" -lt 100 ]
do
  sleep 0.1
  i=$((i + 1))
done
if process_alive "$SCRIPT_PID"
then
  fail_check "the script still runs 10 seconds after SIGINT"
  kill -KILL "$SCRIPT_PID" 2>/dev/null || true
fi
if wait "$SCRIPT_PID"
then
  INT_STATUS=0
else
  INT_STATUS=$?
fi
STATUS="$INT_STATUS"
OUTPUT="$(cat "${WORK}/interrupt.out")"
expect_status 130
for pid_file in stub.pid child.pid
do
  pid="$(cat "$BLOCK_DIR/$pid_file" 2>/dev/null || echo 0)"
  i=0
  while [ "$pid" -gt 0 ] && process_alive "$pid" && [ "$i" -lt 50 ]
  do
    sleep 0.1
    i=$((i + 1))
  done
  if [ "$pid" -gt 0 ] && process_alive "$pid"
  then
    fail_check "$pid_file process is still running after the interrupt"
    kill -KILL "$pid" 2>/dev/null || true
  fi
done
if [ -n "$(ls -A "$TMP_EMPTY")" ]
then
  fail_check "the scratch directory was not removed after the interrupt"
fi
finish_case

APT_LIBGTK="apt-get install --no-install-recommends -y -qq libgtk-3-0t64"

begin_case "ICU runtime: one apt call names libgtk, then the newest ICU version offered"
STUB_ICU_PACKAGES="libicu74 libicu78"
run_script
expect_status 0
expect_call "$APT_LIBGTK libicu78"
finish_case

begin_case "ICU runtime: a release that offers only libicu74 installs libicu74"
STUB_ICU_PACKAGES="libicu74"
run_script
expect_status 0
expect_call "$APT_LIBGTK libicu74"
finish_case

begin_case "ICU runtime: names that are not libicuNN and versions above 80 are ignored"
STUB_ICU_PACKAGES="libicu-dev libicu4j-java libicu78 libicu80 libicu81"
run_script
expect_status 0
expect_call "$APT_LIBGTK libicu80"
expect_no_call "libicu81"
expect_no_call "libicu-dev"
expect_no_call "libicu4j"
finish_case

begin_case "ICU runtime: no package in range fails before any apt install"
STUB_ICU_PACKAGES="libicu81"
run_script
expect_status 1
expect_output "apt-get update"
expect_no_call "apt-get install"
expect_no_mutating_install
finish_case

begin_case "ICU runtime: an empty pkgnames answer fails before any apt install"
STUB_ICU_PACKAGES=""
run_script
expect_status 1
expect_output "apt-get update"
expect_no_call "apt-get install"
finish_case

if [ -e typescript ]
then
  echo "a typescript file was created in the working directory" >&2
  FAILURES=$((FAILURES + 1))
fi

if [ "$FAILURES" -gt 0 ]
then
  printf '%s case(s) failed\n' "$FAILURES" >&2
  exit 1
fi

echo "all unity editor re-run test cases passed"
