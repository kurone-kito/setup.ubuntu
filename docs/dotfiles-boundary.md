---
type: reference
title: Dotfiles and mise ownership boundary
description: Records this Ubuntu stack's apt/Homebrew/mise install-ownership layers and why five tools moved to dotfiles.
tags: [dotfiles, mise, ownership]
---

# Dotfiles and mise ownership boundary

<!-- cspell:words mikefarah tealdeer winget -->

This repository's install surface is split across several layers, only
some of which this repository owns. This page records the split so a
later session does not need to reconstruct it from git history.

## Ownership table

| Layer                                                             | Owner                | Examples                                                    |
| ------------------------------------------------------------------ | --------------------- | ------------------------------------------------------------- |
| apt (`cloud-init.yml` + `lib/base-install.sh`)                     | This repository       | Base packages installed at cloud-init time                    |
| Homebrew (`lib/Brewfile`)                                          | This repository       | Formulae installed via `brew bundle`                           |
| This repository's `lib/mise.sh`                                    | This repository       | Node.js, Bitwarden CLI                                         |
| dotfiles mise (`home/dot_config/mise/config.toml`)                 | `dotfiles`            | The cross-platform CLI list, including the five tools below   |
| dotfiles / chezmoi                                                  | `dotfiles`            | User-facing configuration (see [desktop.md](desktop.md) / [unity.md](unity.md) for the layer-specific detail) |

## Why some installs moved

Windows portable `winget` packages create NTFS symlinks under
`%LOCALAPPDATA%\Microsoft\WinGet\Links`, and inbound OpenSSH sessions
cannot traverse those reparse points. mise's shims avoid that failure
mode with one fixed PATH entry instead. That mechanism, and the
resulting decision to share one cross-platform mise tool list across
platforms, is recorded in
[`kurone-kito/setup.windows#111`](https://github.com/kurone-kito/setup.windows/issues/111)
and
[setup.windows `docs/dotfiles-boundary.md` §7](https://github.com/kurone-kito/setup.windows/blob/master/docs/dotfiles-boundary.md#7-why-cli-tools-moved-to-dotfiles-at-all).
[`kurone-kito/dotfiles#257`](https://github.com/kurone-kito/dotfiles/issues/257)
added the shared mise config, and this repository's
[#105](https://github.com/kurone-kito/setup.ubuntu/issues/105) then
dropped the overlapping apt copies so this platform would not keep two
install paths for the same tool.

## Handed-off inventory

`jq`, `fzf`, `mkcert`, `git-delta` (mise tool name `delta`), and
`tealdeer` (binary name `tldr`) are no longer installed by `./setup`.
They appear on `PATH` after `chezmoi apply` deploys dotfiles' mise
config.

## Explicit non-moves

- **`yq` stays.** `lib/base-install.sh` apt-installs `kislyuk/yq` and
  calls it by absolute path (`/usr/bin/yq`) to parse `cloud-init.yml`
  before `lib/mise.sh` runs. Dotfiles' mise `yq` is `mikefarah/yq` and
  uses incompatible CLI syntax, so it must never shadow the bootstrap
  parser (see
  [#104](https://github.com/kurone-kito/setup.ubuntu/issues/104)).
- **`terraform` and `fastfetch` were never in scope here.** Neither
  ever appeared in this repository's `cloud-init.yml` (`hyfetch` is a
  different, unrelated tool) — there is nothing to opt out.

## Remaining overlap

`lib/mise.sh` still installs Node.js and Bitwarden CLI, and dotfiles'
mise config also declares `node` and `npm:@bitwarden/cli`. This is
current fact, not something this page changes — removing either
install path is out of scope here.

## Operator consequence

`./setup` installs chezmoi and mise, but it never runs `chezmoi apply`.
The five handed-off CLIs above are missing on a machine that has not
applied dotfiles. One Ubuntu-specific PATH note: `lib/homebrew.sh`
appends `brew shellenv` to `~/.bashrc`, so a fresh bash session after
`./setup` can already see `mise` (itself a Homebrew formula) without
further action.
