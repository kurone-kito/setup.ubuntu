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

# Return success when running under WSL (1 or 2). Several independent signals
# are checked so a missing ${WSL_DISTRO_NAME} (custom init, root sessions)
# cannot misclassify a WSL host as bare-metal. WSL1 and WSL2 are deliberately
# grouped: neither can use a Linux GPU driver (WSL2 exposes the Windows driver
# through /dev/dxg / WSLg, WSL1 has no GPU passthrough at all), so both must
# skip the GPU-driver stage. Treating WSL1 as bare-metal would be the unsafe
# choice, since the bare-metal path may install a GPU driver.
is_wsl() {
  if [ -n "${WSL_DISTRO_NAME:-}" ]; then return 0; fi
  if [ -e /run/WSL ]; then return 0; fi
  if [ -e /proc/sys/fs/binfmt_misc/WSLInterop ]; then return 0; fi
  if [ -r /proc/sys/kernel/osrelease ] &&
    grep -qiE 'microsoft|wsl' /proc/sys/kernel/osrelease; then return 0; fi
  if [ -r /proc/version ] &&
    grep -qiE 'microsoft|wsl' /proc/version; then return 0; fi
  return 1
}

# Echo one of: wsl | baremetal | unsupported.
detect_environment() {
  if is_wsl; then echo wsl; return; fi
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
# 0x8086 Intel. Only display devices are inspected (the DRM card nodes plus the
# VGA/3D/Display lines from lspci) so unrelated PCI devices such as NICs or the
# chipset cannot be mistaken for a GPU. Vendors are tested in priority order
# (NVIDIA, then AMD, then Intel) across both sources, so a discrete GPU is
# preferred over an integrated one — the discrete device is the one usable for
# GPU streaming. NVIDIA requires a real device (a 0x10de display node, a working
# nvidia-smi, an /dev/nvidia0 node, or an lspci display line), not merely the
# presence of the nvidia-smi binary.
detect_gpu_vendor() {
  ids=""
  for f in /sys/class/drm/card*/device/vendor; do
    [ -r "$f" ] || continue
    ids="${ids} $(cat "$f" 2>/dev/null || true)"
  done
  gpus=""
  if command -v lspci >/dev/null 2>&1; then
    gpus="$(lspci 2>/dev/null | grep -iE 'vga|3d|display' || true)"
  fi

  if printf '%s' " ${ids} " | grep -q '0x10de' ||
    { command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi -L >/dev/null 2>&1; } ||
    [ -e /dev/nvidia0 ] ||
    printf '%s\n' "${gpus}" | grep -qiE 'nvidia'; then
    echo nvidia
    return
  fi
  if printf '%s' " ${ids} " | grep -q '0x1002' ||
    printf '%s\n' "${gpus}" | grep -qiE 'amd|ati|radeon'; then
    echo amd
    return
  fi
  if printf '%s' " ${ids} " | grep -q '0x8086' ||
    printf '%s\n' "${gpus}" | grep -qiE 'intel'; then
    echo intel
    return
  fi
  echo none
}

# --- install stages (skeletons; bodies added by sibling issues) ---

stage_baseline_desktop() { # XFCE (xubuntu-core) + xrdp
  log "installing XFCE (xubuntu-core) + xrdp + xorgxrdp"
  # Refresh the index defensively so a standalone or WSL invocation does not
  # abort the install on a stale cache.
  sudo apt-get update
  # --no-install-recommends keeps the display manager (a recommend of
  # xubuntu-core) out, so the host stays headless by default.
  sudo apt-get install -y --no-install-recommends \
    xubuntu-core xrdp xorgxrdp

  # systemd actions only apply where systemd is the init system (bare-metal,
  # and WSL only when systemd is enabled in wsl.conf). Detect it once.
  if [ -d /run/systemd/system ]; then
    # Keep the host headless-by-default: force the multi-user (CLI) target and
    # disable any display manager that may already be present. The GUI is
    # reached over xrdp on connect, not via a local login screen.
    sudo systemctl set-default multi-user.target >/dev/null 2>&1 || true
    for dm in lightdm gdm3 sddm lxdm nodm; do
      if systemctl list-unit-files "${dm}.service" >/dev/null 2>&1 &&
        systemctl is-enabled "${dm}.service" >/dev/null 2>&1; then
        sudo systemctl disable "${dm}.service" >/dev/null 2>&1 || true
      fi
    done
    # Enable and start xrdp; surface a real failure instead of hiding it.
    sudo systemctl enable --now xrdp ||
      log "warning: could not enable/start xrdp; start it manually"
    log "default systemd target: $(systemctl get-default 2>/dev/null || echo unknown)"
  else
    log "systemd not detected (e.g. WSL without systemd): start xrdp manually"
  fi

  # xrdp honors a user-provided ~/.xsession (managed by dotfiles) when present;
  # otherwise it falls back to the system x-session-manager set here, so a
  # connection lands in XFCE out of the box. The alternative may be absent on a
  # minimal image, so a failure here is non-fatal.
  xfce_session="$(command -v xfce4-session || true)"
  if [ -n "${xfce_session}" ] &&
    command -v update-alternatives >/dev/null 2>&1; then
    sudo update-alternatives --set x-session-manager "${xfce_session}" ||
      log "warning: could not set XFCE as the default x-session-manager"
  fi
}

stage_sunshine() { # Sunshine host + vendor-aware encoder -> #30
  log "Sunshine host + encoder selection: not yet implemented (#30)"
  return 0
}

stage_gpu_display() { # GPU driver + headless virtual display -> #31
  # Defense-in-depth: never install a Linux GPU driver under WSL (1 or 2).
  if is_wsl; then
    log "WSL detected: refusing GPU driver install (no Linux GPU driver under WSL)"
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
  wsl)
    plan "install XFCE (xubuntu-core) + xrdp"
    plan "WSL: rely on WSLg (WSL2); skip Linux GPU driver and bare-metal Sunshine"
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
wsl)
  stage_baseline_desktop
  log "WSL: relying on WSLg (WSL2); skipping Linux GPU driver and bare-metal Sunshine"
  ;;
unsupported)
  log "environment not supported for the desktop layer; nothing to do"
  ;;
esac
