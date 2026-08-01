# Optional Unity layer

The Unity CLI installs in the default `./setup` path — it needs no `sudo` and
works on a headless host. The Unity **Editors** themselves are **opt-in**:
installing an Editor needs no license, but running one does, and this
repository deliberately does not hold the credentials to activate one.

## Enabling it

```sh
./setup --unity            # install the pinned Unity Editors (real Ubuntu host)
./setup --unity --dry-run  # print the plan only; install nothing
```

`--dry-run` resolves and prints both Editors' versions, the module set, and
the estimated disk requirement, then exits without installing anything or
requiring `sudo`. `--unity` is rejected on the VM / non-Ubuntu path because it
cannot be forwarded into the launched VM; run it on a real Ubuntu host
instead.

`--unity --dry-run` needs the Unity CLI already on `PATH` to resolve live
version data — it does not install the CLI itself, since that would make
`--dry-run` install something. Any prior `./setup` run already has it (the
CLI installs unconditionally); on a genuinely first-ever run, `--unity
--dry-run` reports that the CLI isn't there yet and to run `./setup` once
first.

## What gets installed

Two pinned Editors, each with the `android`, `linux-il2cpp`, and
`windows-mono` modules (plus their child modules):

- **`6000.3.x`** (the current release in the `6.3` LTS stream) — for general
  game projects.
- **`2022.3.22f1`** (changeset `887be4894c44`) — the exact build VRChat's SDK
  targets.

## Version policy

The general-games Editor is selected with the explicit `6.3` selector, not
`unity install lts`: Unity's LTS stream carries two active lines at once
(`6000.0.x` and `6000.3.x`), and the `lts` alias resolves to whichever line
was patched most recently — often the `6000.0` line. Selecting `6.3`
explicitly avoids silently installing the wrong stream. The install step
fails loudly if the resolved version doesn't start with `6000.3.`.

The VRChat Editor is old enough that Unity's release list may not carry it by
version alone, so its changeset (`887be4894c44`) pins the install regardless.

## Release channel

The Unity CLI itself (installed unconditionally, not part of `--unity`) is
pinned to the `beta` release channel in `lib/unity.sh`, in one place: Unity
has not published a stable release manifest yet (the stable manifest 404s;
the beta manifest currently resolves). Drop the pin once Unity ships a stable
manifest.

## Disk budget

The default module set for both Editors combined is measured at roughly
**27 GiB installed** / **13 GiB downloaded**. The preflight in
`lib/unity-editors.sh` requires ~30 GiB free at the Unity CLI's configured
install path before downloading anything, and rejects the run otherwise. To
trim the footprint, run `unity install <version> -m <module...>` directly
with a smaller module list instead of `./setup --unity` — for example,
omitting `--cm` skips the Android SDK/NDK toolchain modules it bundles, or
dropping `android` from `-m` entirely skips Android support altogether.

## Licensing handoff

`./setup --unity` installs both Editors **unlicensed**. Installing needs no
license; running one does, and activation is the operator's step:

- `unity auth login` — interactive device-flow login (a personal license).
- A **serial** for a Unity Pro/Enterprise seat.
- The **service-account** / floating-license paths, for headless CI/agent use.

This repository holds no Unity credentials of any kind, and does not perform
any of the above automatically.

## Relationship to `--desktop`

Running the Unity Editor's GUI needs a graphical session: the
[optional desktop layer](desktop.md) (or WSLg under WSL2) — see that document
for the client matrix, GPU story, and remote-access setup. Headless work
(`-batchmode -nographics`, CI builds, automation) needs neither `--desktop`
nor a display.

## WSL2

Consistent with [docs/desktop.md](desktop.md), WSL2 is treated as the primary
Unity host. It has no Linux GPU driver of its own, so the Windows GPU is
reached through WSLg; no extra `--unity`-side configuration is needed for
that.

## VRChat on Linux (unofficial)

VRChat's SDK does not officially support Linux. World uploads from a Linux
Editor have worked since SDK 3.7.6 in practice, but the platform is
unsupported and avatar workflows in particular may hit problems. `vrc-get`
(already installed by default) is the cross-platform stand-in for the
Windows-only VRChat Creator Companion.

## Configuration handoff (chezmoi / dotfiles)

This repository **installs** the Unity CLI and the two pinned Editors and
performs no further configuration. Editor preferences, project settings, and
license activation all belong to the user/dotfiles side, matching the same
chezmoi boundary [docs/desktop.md](desktop.md) draws for the desktop layer.

## Tuning knobs

- `--unity` — install the pinned Unity Editors.
- `--unity --dry-run` — print the plan and install nothing.
