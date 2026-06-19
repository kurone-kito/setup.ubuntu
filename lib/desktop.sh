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

# Experimental opt-in: install Sunshine inside WSL (software encoding only).
case "${DESKTOP_SUNSHINE_WSL:-0}" in
1 | true | yes | on) DESKTOP_SUNSHINE_WSL=1 ;;
*) DESKTOP_SUNSHINE_WSL=0 ;;
esac

# Opt-in: configure a dummy headless virtual display for AMD/Intel. It can
# override a connected monitor, so it is only for genuinely monitor-less hosts.
case "${DESKTOP_DUMMY_DISPLAY:-0}" in
1 | true | yes | on) DESKTOP_DUMMY_DISPLAY=1 ;;
*) DESKTOP_DUMMY_DISPLAY=0 ;;
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
    sudo systemctl set-default multi-user.target >/dev/null 2>&1 ||
      log "warning: could not set multi-user.target; the host may boot to a GUI"
    for dm in lightdm gdm3 sddm lxdm nodm; do
      if systemctl list-unit-files "${dm}.service" >/dev/null 2>&1 &&
        systemctl is-enabled "${dm}.service" >/dev/null 2>&1; then
        # --now also stops a currently-running login screen, not just the next
        # boot, so the host is headless immediately.
        sudo systemctl disable --now "${dm}.service" >/dev/null 2>&1 ||
          log "warning: could not disable ${dm}; it may still show a login screen"
      fi
    done
    # xrdp is the access path for the desktop layer; if it cannot be enabled on a
    # systemd host the desktop is unreachable, so fail loudly rather than leaving
    # a broken install behind.
    sudo systemctl enable --now xrdp || {
      log "error: failed to enable xrdp (required for the desktop layer)"
      exit 1
    }
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

# Map the detected GPU vendor to a Sunshine encoder family. VAAPI is the
# portable Linux hardware path for both Intel and AMD; NVENC is used for NVIDIA;
# anything else falls back to software (x264).
select_encoder() {
  case "${GPU_VENDOR}" in
  nvidia) echo nvenc ;;
  amd | intel) echo vaapi ;;
  *) echo software ;;
  esac
}

stage_sunshine() { # Sunshine host + vendor-aware encoder
  encoder="$(select_encoder)"
  # NVENC is not guaranteed under WSL, so the experimental WSL path uses software.
  if is_wsl; then
    encoder=software
    log "Sunshine on WSL is experimental: using software encoding (NVENC not guaranteed under WSL)"
  fi
  # Install the Sunshine .deb unless it is already present (idempotent). The
  # encoder runtime below is ensured either way, so a pre-installed host still
  # gets hardware-encoding support.
  if command -v sunshine >/dev/null 2>&1; then
    log "Sunshine already installed; ensuring encoder runtime (encoder: ${encoder})"
  else
    log "installing Sunshine host (encoder: ${encoder})"

    # shellcheck source=/dev/null
    ubuntu_ver="$(. /etc/os-release 2>/dev/null; printf '%s' "${VERSION_ID:-}")"
    arch="$(dpkg --print-architecture 2>/dev/null || echo unknown)"
    case "${arch}" in
    amd64 | arm64) ;;
    *)
      log "warning: no Sunshine package for architecture '${arch}'; skipping"
      return 0
      ;;
    esac
    if [ -z "${ubuntu_ver}" ]; then
      log "warning: cannot determine Ubuntu version; skipping Sunshine install"
      return 0
    fi

    # Sunshine is published as a .deb by LizardByte (not in the Ubuntu archive),
    # with prebuilt packages for LTS-class releases. Fetch the build matching
    # this Ubuntu release/arch and let apt resolve deps. A failure here is
    # non-fatal: the xrdp desktop from the baseline stage still works.
    deb="$(mktemp --suffix=.deb)"
    url="https://github.com/LizardByte/Sunshine/releases/latest/download/sunshine-ubuntu-${ubuntu_ver}-${arch}.deb"
    if curl -fsSL "${url}" -o "${deb}" &&
      sudo apt-get install -y --no-install-recommends "${deb}"; then
      log "Sunshine installed"
    else
      log "warning: could not download/install Sunshine for Ubuntu ${ubuntu_ver}/${arch} (no matching LizardByte build, or a network/apt error); the xrdp desktop is unaffected"
      rm -f "${deb}"
      return 0
    fi
    rm -f "${deb}"
  fi

  # Install the runtime the selected encoder needs so Sunshine's auto-detection
  # can use hardware encoding; the encoder is chosen in Sunshine's user config,
  # which dotfiles owns. NVENC ships with the NVIDIA driver (GPU-driver stage);
  # software encoding needs nothing extra.
  case "${encoder}" in
  vaapi)
    sudo apt-get install -y --no-install-recommends vainfo mesa-va-drivers ||
      log "warning: could not install the VAAPI runtime; Sunshine may use software"
    if [ "${GPU_VENDOR}" = intel ]; then
      sudo apt-get install -y --no-install-recommends intel-media-va-driver ||
        log "warning: intel-media-va-driver unavailable; mesa VAAPI will be used"
    fi
    ;;
  nvenc) log "NVENC will use the NVIDIA driver (installed by the GPU-driver stage)" ;;
  software) log "no hardware encoder: Sunshine will use software (x264) encoding" ;;
  esac

  log "Sunshine user config (~/.config/sunshine) is delegated to dotfiles"
}

stage_gpu_display() { # GPU driver + headless virtual display
  # Defense-in-depth: never install a Linux GPU driver under WSL (1 or 2).
  if is_wsl; then
    log "WSL detected: refusing GPU driver install (no Linux GPU driver under WSL)"
    return 0
  fi
  # This stage is the least critical part of the desktop layer (a streaming
  # nicety), and the xrdp desktop already works, so a package failure degrades
  # gracefully instead of aborting the whole setup.
  sudo install -d /etc/X11/xorg.conf.d ||
    { log "warning: could not create /etc/X11/xorg.conf.d; skipping GPU display setup"; return 0; }
  case "${GPU_VENDOR}" in
  nvidia)
    log "installing the NVIDIA driver and enabling a headless virtual display"
    sudo apt-get install -y --no-install-recommends ubuntu-drivers-common ||
      { log "warning: could not install ubuntu-drivers-common; skipping NVIDIA driver"; return 0; }
    if command -v ubuntu-drivers >/dev/null 2>&1; then
      sudo ubuntu-drivers autoinstall ||
        log "warning: ubuntu-drivers could not auto-install an NVIDIA driver"
    else
      log "warning: ubuntu-drivers not found; install the NVIDIA driver manually"
    fi
    # AllowEmptyInitialConfiguration coexists with the real driver and lets the
    # GPU X server start with no monitor attached, so it is safe even when a
    # monitor is present.
    sudo tee /etc/X11/xorg.conf.d/10-nvidia-headless.conf >/dev/null <<'EOF'
Section "Device"
    Identifier "nvidia-headless"
    Driver "nvidia"
    Option "AllowEmptyInitialConfiguration" "true"
EndSection
EOF
    ;;
  amd | intel)
    log "ensuring the ${GPU_VENDOR} userspace stack (the kernel driver is built in)"
    sudo apt-get install -y --no-install-recommends mesa-utils libgl1-mesa-dri ||
      log "warning: could not install the ${GPU_VENDOR} mesa userspace"
    # The dummy driver can override a connected monitor, so the headless display
    # is opt-in (DESKTOP_DUMMY_DISPLAY=1) and intended for monitor-less hosts.
    if [ "${DESKTOP_DUMMY_DISPLAY}" = 1 ]; then
      sudo apt-get install -y --no-install-recommends xserver-xorg-video-dummy ||
        { log "warning: could not install xserver-xorg-video-dummy; skipping dummy display"; return 0; }
      sudo tee /etc/X11/xorg.conf.d/10-headless-dummy.conf >/dev/null <<'EOF'
Section "Device"
    Identifier "headless-dummy"
    Driver "dummy"
    VideoRam 256000
EndSection
Section "Monitor"
    Identifier "headless-monitor"
    HorizSync 5.0 - 1000.0
    VertRefresh 5.0 - 200.0
EndSection
Section "Screen"
    Identifier "headless-screen"
    Device "headless-dummy"
    Monitor "headless-monitor"
    DefaultDepth 24
    SubSection "Display"
        Depth 24
        Modes "1920x1080"
    EndSubSection
EndSection
EOF
      log "dummy headless display configured (overrides any local monitor)"
    else
      log "${GPU_VENDOR}: skipping the dummy headless display (set DESKTOP_DUMMY_DISPLAY=1 on a monitor-less host)"
    fi
    ;;
  *)
    log "no GPU vendor detected; skipping GPU driver / virtual display"
    return 0
    ;;
  esac
  log "GPU display stage complete"
}

print_plan() {
  plan "environment: ${ENVIRONMENT}"
  plan "gpu vendor:  ${GPU_VENDOR}"
  case "${ENVIRONMENT}" in
  baremetal)
    plan "install XFCE (xubuntu-core) + xrdp; no display manager (boot stays CLI)"
    plan "install Sunshine (encoder: $(select_encoder))"
    case "${GPU_VENDOR}" in
    nvidia) plan "install NVIDIA driver (ubuntu-drivers) + AllowEmptyInitialConfiguration headless display" ;;
    amd | intel)
      if [ "${DESKTOP_DUMMY_DISPLAY}" = 1 ]; then
        plan "install ${GPU_VENDOR} mesa userspace + dummy headless display (overrides a local monitor)"
      else
        plan "install ${GPU_VENDOR} mesa userspace (set DESKTOP_DUMMY_DISPLAY=1 for a dummy headless display)"
      fi
      ;;
    *) plan "no GPU: skip GPU driver and headless virtual display" ;;
    esac
    ;;
  wsl)
    plan "install XFCE (xubuntu-core) + xrdp"
    if [ "${DESKTOP_SUNSHINE_WSL}" = 1 ]; then
      plan "WSL: install Sunshine (experimental, software encoding)"
    else
      plan "WSL: rely on WSLg (WSL2); skip Linux GPU driver and bare-metal Sunshine"
    fi
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
  if [ "${DESKTOP_SUNSHINE_WSL}" = 1 ]; then
    log "WSL: --desktop-sunshine-wsl set; installing Sunshine (experimental)"
    stage_sunshine
  else
    log "WSL: relying on WSLg (WSL2); skipping Linux GPU driver and bare-metal Sunshine"
  fi
  ;;
unsupported)
  log "environment not supported for the desktop layer; nothing to do"
  ;;
esac
