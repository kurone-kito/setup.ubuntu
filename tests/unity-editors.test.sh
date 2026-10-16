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
        if has_word "$version" "$STUB_INSTALLED"
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
            printf '{"code":"COMMAND_FAILED","message":"Editor already installed in this location."}\n'
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
        esac
        echo "installed ${version}"
        ;;
    esac
    ;;
  install-modules)
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
        if [ -z "${STUB_MISSING:-}" ]
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
    if [ -z "${STUB_MISSING:-}" ]
    then
      echo "No modules found to install."
      exit 6
    fi
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
  export STUB_INSTALLED="" STUB_GENERAL_RESOLVED="6000.3.10f1"
  export STUB_MISSING="" STUB_PROBE="" STUB_NO_FLAG="" STUB_LANG="en" STUB_LANG_FAIL="" STUB_MUTATING="ok" STUB_MODULES="ok" STUB_DF_GIB="100"
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

if [ "$FAILURES" -gt 0 ]
then
  printf '%s case(s) failed\n' "$FAILURES" >&2
  exit 1
fi

echo "all unity editor re-run test cases passed"
