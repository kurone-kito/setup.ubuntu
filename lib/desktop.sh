#!/bin/sh
# -*- mode: sh -*-
# vim: set ft=sh :

set -eu
cd "$(cd "$(dirname "$0")"; pwd)/.."

# Opt-in desktop layer foundation (issue #28). This script performs only
# environment/GPU detection and prints a dry-run plan; the actual install
# stages are filled in by sibling issues (#29 XFCE + xrdp, #30 Sunshine,
# #31 GPU driver + virtual display). The default CLI setup never calls it.

# Normalize to 0|1 so a value such as "true" cannot abort a numeric test and so
# direct invocation behaves the same as going through setup.
case "${DESKTOP_DRY_RUN:-0}" in
1 | true | yes | on) DESKTOP_DRY_RUN=1 ;;
*) DESKTOP_DRY_RUN=0 ;;
esac

log() { printf '[desktop] %s\n' "$*"; }
plan() { printf '[desktop:plan] %s\n' "$*"; }

# Return success when running under WSL2. Several independent signals are
# checked so a missing ${WSL_DISTRO_NAME} (custom init, root sessions) cannot
# misclassify a WSL2 host as bare-metal and trigger a Linux GPU driver install,
# which would break WSLg (the Windows-side driver exposed through /dev/dxg).
is_wsl2() {
  if [ -n "${WSL_DISTRO_NAME:-}" ]; then return 0; fi
  if [ -e /run/WSL ]; then return 0; fi
  if [ -e /proc/sys/fs/binfmt_misc/WSLInterop ]; then return 0; fi
  if [ -r /proc/sys/kernel/osrelease ] &&
    grep -qiE 'microsoft|wsl' /proc/sys/kernel/osrelease; then return 0; fi
  if [ -r /proc/version ] &&
    grep -qiE 'microsoft|wsl' /proc/version; then return 0; fi
  return 1
}

# Echo one of: wsl2 | baremetal | unsupported.
detect_environment() {
  if is_wsl2; then echo wsl2; return; fi
  if command -v apt-get >/dev/null 2>&1 && [ -r /etc/os-release ]; then
    # /etc/os-release is an external system file ShellCheck cannot follow.
    # shellcheck source=/dev/null
    . /etc/os-release
    if [ "${ID:-}" = ubuntu ]; then echo baremetal; return; fi
  fi
  echo unsupported
}

# Echo one of: nvidia | amd | intel | none. Never errors, even with no GPU and
# no detection tools installed. PCI vendor IDs: 0x10de NVIDIA, 0x1002 AMD/ATI,
# 0x8086 Intel. Only display devices are inspected (the DRM card nodes, and the
# VGA/3D/Display lines from lspci) so unrelated PCI devices such as NICs or the
# chipset cannot be mistaken for a GPU. A discrete NVIDIA GPU is preferred over
# an integrated one because it is the device usable for GPU streaming.
detect_gpu_vendor() {
  ids=""
  for f in /sys/class/drm/card*/device/vendor; do
    [ -r "$f" ] || continue
    ids="${ids} $(cat "$f" 2>/dev/null || true)"
  done
  case " ${ids} " in
  *0x10de*) echo nvidia; return ;;
  esac
  if command -v nvidia-smi >/dev/null 2>&1 || [ -e /dev/nvidia0 ]; then
    echo nvidia
    return
  fi
  case " ${ids} " in
  *0x1002*) echo amd; return ;;
  *0x8086*) echo intel; return ;;
  esac
  if command -v lspci >/dev/null 2>&1; then
    gpus="$(lspci 2>/dev/null | grep -iE 'vga|3d|display' || true)"
    if printf '%s\n' "${gpus}" | grep -qiE 'nvidia'; then echo nvidia; return; fi
    if printf '%s\n' "${gpus}" | grep -qiE 'amd|ati|radeon'; then echo amd; return; fi
    if printf '%s\n' "${gpus}" | grep -qiE 'intel'; then echo intel; return; fi
  fi
  echo none
}

# --- install stages (skeletons; bodies added by sibling issues) ---

stage_baseline_desktop() { # XFCE (xubuntu-core) + xrdp -> #29
  log "baseline desktop (XFCE + xrdp): not yet implemented (#29)"
  return 0
}

stage_sunshine() { # Sunshine host + vendor-aware encoder -> #30
  log "Sunshine host + encoder selection: not yet implemented (#30)"
  return 0
}

stage_gpu_display() { # GPU driver + headless virtual display -> #31
  # Defense-in-depth: never install a Linux GPU driver under WSL2.
  if is_wsl2; then
    log "WSL2 detected: refusing GPU driver install (WSLg uses the Windows driver)"
    return 0
  fi
  log "GPU driver + headless virtual display: not yet implemented (#31)"
  return 0
}

print_plan() {
  plan "environment: ${ENVIRONMENT}"
  plan "gpu vendor:  ${GPU_VENDOR}"
  case "${ENVIRONMENT}" in
  baremetal)
    plan "install XFCE (xubuntu-core) + xrdp; no display manager (boot stays CLI)"
    plan "install Sunshine; encoder for vendor '${GPU_VENDOR}' (software if none)"
    if [ "${GPU_VENDOR}" = none ]; then
      plan "no GPU: skip GPU driver and headless virtual display"
    else
      plan "install '${GPU_VENDOR}' GPU driver + headless virtual display"
    fi
    ;;
  wsl2)
    plan "install XFCE (xubuntu-core) + xrdp"
    plan "WSL2: rely on WSLg; skip Linux GPU driver and bare-metal Sunshine"
    ;;
  unsupported)
    plan "environment not supported for the desktop layer; nothing to do"
    ;;
  esac
}

ENVIRONMENT="$(detect_environment)"
GPU_VENDOR="$(detect_gpu_vendor)"

if [ "${DESKTOP_DRY_RUN}" = 1 ]; then
  print_plan
  exit 0
fi

log "environment=${ENVIRONMENT} gpu=${GPU_VENDOR}"
case "${ENVIRONMENT}" in
baremetal)
  stage_baseline_desktop
  stage_sunshine
  if [ "${GPU_VENDOR}" = none ]; then
    log "no GPU detected: skipping GPU driver / virtual display (software encode only)"
  else
    stage_gpu_display
  fi
  ;;
wsl2)
  stage_baseline_desktop
  log "WSL2: relying on WSLg; skipping Linux GPU driver and bare-metal Sunshine"
  ;;
unsupported)
  log "environment not supported for the desktop layer; nothing to do"
  ;;
esac
