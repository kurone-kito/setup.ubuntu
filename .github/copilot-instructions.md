# Guidelines for AI Agents

Automated CLI dev-environment setup for Ubuntu 22.04+ (including WSL).
This project installs packages and tools only — configuration beyond
install-time minimums belongs in the
[dotfiles](https://github.com/kurone-kito/dotfiles) repository.

Related projects:
[setup.macos](https://github.com/kurone-kito/setup.macos),
[setup.windows](https://github.com/kurone-kito/setup.windows).

## Tooling priority and compatibility

This repository is intentionally optimized for GitHub Copilot CLI and
VS Code Copilot Chat because they are the primary tools used for
day-to-day work and benchmarking. Codex CLI is a supplementary target.

`AGENTS.md` exists as a compatibility entry point for Codex CLI, while
`CLAUDE.md` and `GEMINI.md` provide minimal support for other agents.
Keep this file as the canonical, fully detailed guide.

## Architecture

### Directory structure

```txt
setup                    # Entry point (POSIX sh)
nuke                     # Cleanup / VM destruction
cloud-init.yml           # APT package manifest + VM init config
main.tf                  # Terraform config (Multipass VM)
lib/
  base-install.sh        # APT package installation (from cloud-init.yml)
  homebrew.sh            # Linuxbrew installation + Brewfile bundle
  Brewfile               # Homebrew package manifest (Ruby DSL)
  mise.sh                # mise-managed tool installation
  docker.sh              # Docker CE installation (official repo)
  teardown.sh            # Cleanup (brew cleanup, apt autoremove)
  locale.sh              # Locale, timezone, keyboard configuration
  virtual.sh             # Terraform init + Multipass VM creation
  deploy.sh              # Deploy scripts to VM via tar + multipass
etc/
  default/keyboard       # Japanese keyboard layout (jp106)
```

### Execution flow

**Native mode** (on Ubuntu):

```txt
setup → sudo keep-alive
      → lib/base-install.sh    (APT packages from cloud-init.yml)
      → lib/homebrew.sh        (Linuxbrew + Brewfile)
      → lib/mise.sh            (Node.js, Bitwarden CLI)
      → lib/docker.sh          (Docker CE)
      → lib/teardown.sh        (cleanup)
      → lib/locale.sh          (ja_JP.UTF-8, Asia/Tokyo, jp106)
```

**VM mode** (non-Ubuntu or `./setup -v`):

```txt
setup → lib/virtual.sh   (terraform init + apply → Multipass VM)
      → lib/deploy.sh    (tar + multipass transfer → execute)
```

### Package management — where to add packages

| Source          | Manifest            | When to use                                |
|-----------------|---------------------|--------------------------------------------|
| APT             | `cloud-init.yml`    | Available in Ubuntu default/universe repos |
| Homebrew        | `lib/Brewfile`      | Not in APT, or Homebrew version preferred  |
| mise            | `lib/mise.sh`       | Needs version management (e.g., Node.js)   |
| Docker official | `lib/docker.sh`     | Docker CE and its plugins only             |
| Custom install  | new `lib/<name>.sh` | Complex install requiring its own script   |

When adding an APT package, insert it into the `packages:` list in
`cloud-init.yml` under the appropriate category comment, maintaining
alphabetical order within that category. Update `README.md` to list
the new package under the matching section.

When adding a Homebrew package, append a `brew '<formula>'` line to
`lib/Brewfile` under the appropriate category comment. Update
`README.md` accordingly.

## Conversation

- The conversational language should match the user's language.
  For example, if the user speaks in Japanese, respond in Japanese.
- However, comments and documentation should be written in English
  unless there is a clear context otherwise.
- If uncertainties, concerns, or other implementation issues arise
  while running in Agent mode, promptly switch to Plan mode and ask
  the user questions. In such cases, provide one or more recommended
  response options.
- Outside GitHub Copilot, interpret the `Agent mode` and `Plan mode`
  wording by intent: continue autonomously for low-risk work, but
  pause and ask a concise question when uncertainty or hidden risk
  makes the next step unsafe. When that pause is needed, provide one
  or more recommended response options.

## Commit rules

This project follows
[Conventional Commits](https://www.conventionalcommits.org/).
A `.gitmessage` template is available at the repository root for
guidance when writing commit messages.

### Format

```txt
<type>[optional scope]: <user-facing description>

<body: address purpose, context, and what changed>

[optional footer(s)]
```

### Subject line

- Use the format: `<type>[optional scope]: <description>`
- Write from the **user's perspective** — briefly state what this
  commit solves or improves for the end user or developer
- Write in **lowercase**, imperative mood (e.g., "add", not "added")
- Keep the subject line under **72 characters**
- Do **not** end with a period

### Types

Common types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`,
`chore`, `ci`, `build`, `perf`

### Scopes

Use the following project-specific scopes:

| Scope        | Area                                             |
|--------------|--------------------------------------------------|
| `apt`        | APT packages in `cloud-init.yml`                 |
| `brew`       | Homebrew packages in `lib/Brewfile`              |
| `mise`       | mise-managed tools in `lib/mise.sh`              |
| `docker`     | Docker installation in `lib/docker.sh`           |
| `vm`         | VM / Terraform in `main.tf`, `lib/virtual.sh`    |
| `locale`     | Locale / keyboard in `lib/locale.sh`, `etc/`     |
| `ci`         | GitHub Actions workflows                         |
| `lint`       | Linter configs (cspell, markdownlint)            |
| `readme`     | `README.md` changes                              |
| `docs`       | Other documentation                              |

Keep scopes **lowercase**, short, and consistent.

### Body (line 3+)

The body should address three aspects:

- **Why** — the purpose or motivation behind the change
- **Context** — what was needed, the situation or constraint
- **What changed** — the concrete action taken

Prefer the **why → context → change** order when practical.
Write these as **natural prose** — weave the aspects into
coherent sentences rather than using labeled sections. Labeled
sections (`Why:` / `Context:` / `Change:`) are acceptable only
when explicit paragraph separation improves clarity.

Omit any aspect whose information **cannot be reliably inferred**.
If the subject line is self-explanatory, the body may be omitted
entirely. **Breaking changes must always include a body.**

Wrap body lines at **72 characters**.

### Breaking changes

- Append `!` after the type/scope: `feat!: drop ubuntu 20.04 support`
- Add a `BREAKING CHANGE:` trailer in the footer with a detailed
  explanation of what breaks and migration steps

### Footers / trailers

- `Closes #<issue>` / `Refs #<issue>` — link to issues
- `Co-authored-by: Name <email>` — credit co-authors
- `BREAKING CHANGE: <description>` — detail the breaking change

### Atomic commits

Keep each commit as **small and focused** as possible:

- **One logical change per commit** — if the subject line needs "and",
  consider splitting
- **Separate refactoring** from behavior changes
- **Separate formatting/style** changes from logic changes
- **Separate dependency updates** from code changes
- When in doubt, prefer smaller commits that are easy to review,
  revert, and bisect

### Examples

#### Good — adding a package

```txt
feat(brew): add lazyjj for jujutsu tui

lazyjj provides a terminal UI for jj that is similar to
lazygit. Since jj is already installed via Homebrew, add
lazyjj alongside it in the Brewfile SCM tools section.
```

#### Good — single-line (trivial change)

```txt
fix: correct typo in feature request template
```

#### Good — breaking change

```txt
feat!: drop ubuntu 20.04 support

Ubuntu 20.04 has reached end-of-life and several packages
in cloud-init.yml are no longer available in its repos.
All target environments have been upgraded to 22.04+, so
remove 20.04-specific workarounds and update the minimum
version requirement in the README.

BREAKING CHANGE: ubuntu 20.04 is no longer supported.
Users must upgrade to 22.04 or later.
Closes #12
```

## Coding standards

### General

- **Indentation**: 2 spaces (enforced by `.editorconfig`)
- **Line endings**: LF only (enforced by `.editorconfig` and
  `.gitattributes`)
- **Trailing whitespace**: trimmed (except in Markdown)
- **Final newline**: always present
- **File naming**: lowercase with hyphens (e.g., `base-install.sh`)
  unless constrained by a platform convention (e.g., `CONTRIBUTING.md`)

### Shell scripting conventions

- **Prefer POSIX `sh`** (`#!/bin/sh`) for new scripts. Use `bash`
  (`#!/bin/bash` or `#!/usr/bin/env bash`) only when bash-specific
  features are required (e.g., `mapfile`, arrays).
- **Always start with `set -eu`** — exit on error, treat unset
  variables as errors.
- **Vim modeline**: include `# -*- mode: sh -*-` and
  `# vim: set ft=sh :` after the shebang.
- **Directory navigation**: every `lib/*.sh` script should `cd` to the
  repository root at the top:

  ```sh
  cd "$(cd "$(dirname "$0")"; pwd)/.."
  ```

- **Non-interactive apt**: always use
  `sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends`
  to avoid interactive prompts and minimize installed size.
- **Idempotency**: scripts should be safe to re-run. Use existence
  checks (e.g., `[ -d "/path" ]`) and `|| true` for commands that
  may fail on re-run (e.g., `groupadd`).
- **No custom functions**: scripts use linear, top-to-bottom execution.
  Keep each script focused on one installation phase.
- **Error output**: write error messages to stderr (`>&2`).

### YAML conventions (cloud-init.yml)

- Packages are listed under categorized comments (e.g.,
  `# Archive tools`, `# SCM tools`)
- Maintain **alphabetical order** within each category
- Use the **APT package name** (not the upstream project name)

### Brewfile conventions

- Use `brew '<formula>'` syntax (single quotes)
- Group by category with comments matching `cloud-init.yml` style
- Maintain **alphabetical order** within each category

## Testing

There are no automated unit tests. Validation is performed via:

1. **CI linting** (`cspell` + `markdownlint`) on push and PR
2. **VM integration testing** — run `./setup -v` (or `./setup` on a
   non-Ubuntu host) to provision a Multipass VM and execute the full
   setup. Requires [Multipass](https://multipass.run/) and
   [Terraform](https://www.terraform.io/).
3. **Cleanup** — run `./nuke` to destroy the VM and reset state.

When making changes, ensure `cspell` and `markdownlint` pass. New
technical terms may need to be added to `.cspell.config.yml` `words`.

## Guardrails

- **Do not** modify community documents (CODE_OF_CONDUCT, CONTRIBUTING)
  without explicit approval
- **Scope boundary**: this project handles installation only.
  Configuration beyond install-time defaults belongs in the
  [dotfiles](https://github.com/kurone-kito/dotfiles) repository.
- **Do not** install GUI applications — this project targets CLI
  environments only
