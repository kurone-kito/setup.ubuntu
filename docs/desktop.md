# Optional desktop layer

The default `./setup` installs a CLI-only environment. An **opt-in**
graphical layer can be added for GUI workloads — for example the Unity
Editor over a remote desktop. The default boot stays headless: no display
manager is installed and a graphical session starts only on connect.

## Enabling it

```sh
./setup --desktop            # install the desktop layer (real Ubuntu host)
./setup --desktop --dry-run  # print the plan only; install nothing
```

`--dry-run` (or the `DESKTOP_DRY_RUN=1` environment variable) prints the
per-environment plan and exits without changing anything. `--desktop` is
rejected on the VM / non-Ubuntu path because it cannot be forwarded into the
launched VM; run it on a real Ubuntu host instead.

What it installs, by detected environment and GPU:

- **XFCE** (`xubuntu-core`) + **xrdp** for RDP access. On systemd hosts no
  display manager is enabled and the default target is forced to
  `multi-user.target`; a WSL distro without systemd is left as-is (start xrdp
  manually).
- **Sunshine** for low-latency GPU streaming on bare-metal, with the encoder
  chosen from the detected GPU vendor: NVIDIA → NVENC, AMD/Intel → VAAPI,
  otherwise software. Under WSL it is **skipped by default** (WSLg is used)
  unless the experimental `--desktop-sunshine-wsl` opt-in is set.
- The **GPU driver and a headless virtual display** on bare-metal when a GPU is
  present. For NVIDIA: the driver via `ubuntu-drivers` plus an
  `AllowEmptyInitialConfiguration` Xorg drop-in. For AMD/Intel: the mesa
  userspace (the kernel driver is built in); the dummy headless display is added
  only when `DESKTOP_DUMMY_DISPLAY=1` (it can override a connected monitor).

## Remote-access clients

Connect from iOS / iPadOS / Windows:

- **RDP** — server `xrdp`, client Windows App (Microsoft Remote Desktop). Best
  for day-to-day use, coding, and manual work.
- **Game streaming** — server Sunshine, client Moonlight. Best for the Unity
  play-mode and rapid prototyping (GPU-accelerated, low latency).

## WSL2

WSL2 is the primary Unity host, but it has no Linux GPU driver (it uses the
Windows driver via `/dev/dxg` / WSLg), so the desktop layer never installs a
GPU driver under WSL.

- Locally, GUI apps appear on the Windows desktop through **WSLg**.
- To reach the WSL2 Unity Editor from an iPad, connect to the **Windows host**
  (RDP via Windows App) and use the WSLg windows shown there.
- Sunshine inside WSL2 is **experimental** (NVENC is not guaranteed under WSL).
  Enable it with `./setup --desktop --desktop-sunshine-wsl` (or
  `DESKTOP_SUNSHINE_WSL=1`); it uses software encoding.

## Security

Do **not** expose RDP or Sunshine to the public internet. Reach them over a
private network — Tailscale, WireGuard, or an SSH tunnel. This repository does
not provision that network; it is operator infrastructure.

## Configuration handoff (chezmoi / dotfiles)

This repository **installs** the desktop software and performs the **minimum
enablement** (service enablement, the headless target, the vendor GPU driver,
and the virtual display). User-facing configuration is delegated to the
[dotfiles](https://github.com/kurone-kito/dotfiles) repository (managed with
chezmoi), which owns:

- XFCE look-and-feel (panels, theme, keybindings) under `~/.config/xfce4/`
- Sunshine user config: `~/.config/sunshine/sunshine.conf` and `apps.json`
- the xrdp session entry point `~/.xsession`

## Tuning knobs

- `--desktop` — install the desktop layer.
- `--dry-run` / `DESKTOP_DRY_RUN=1` — print the plan and install nothing.
- `--desktop-sunshine-wsl` / `DESKTOP_SUNSHINE_WSL=1` — experimental Sunshine
  inside WSL (software encoding).
- `DESKTOP_DUMMY_DISPLAY=1` — dummy headless display for AMD/Intel (monitor-less
  hosts only).

## GPU and Unity over a remote session

The Unity Editor needs OpenGL. Plain VNC/RDP renders GL in software, which is
slow; GPU streaming via Sunshine + Moonlight is the path to an accelerated
Editor viewport and play-mode. The GPU-backed virtual display configured by the
desktop layer is what Sunshine captures.
