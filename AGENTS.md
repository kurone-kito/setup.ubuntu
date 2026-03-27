# Guidelines for AI Agents

Automated CLI dev-environment setup for Ubuntu 22.04+ (including WSL).
Install-only scope — configuration belongs in the
[dotfiles](https://github.com/kurone-kito/dotfiles) repository.

## Quick architecture

- **`setup`** — entry point; detects Ubuntu (native) vs other (VM mode)
- **`cloud-init.yml`** — APT package manifest (add packages here)
- **`lib/Brewfile`** — Homebrew package manifest
- **`lib/mise.sh`** — mise-managed tools (Node.js, etc.)
- **`lib/docker.sh`** — Docker CE installation
- **`lib/locale.sh`** — Japanese locale, Asia/Tokyo, jp106 keyboard
- **`main.tf`** — Terraform / Multipass VM for testing

## Shell conventions

- Prefer POSIX `sh`; use `bash` only when needed (e.g., `mapfile`)
- Always `set -eu` at the top
- Include vim modeline: `# -*- mode: sh -*-` / `# vim: set ft=sh :`
- `cd "$(cd "$(dirname "$0")"; pwd)/.."` to reach repo root
- Non-interactive apt:
  `sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends`
- Scripts must be idempotent (safe to re-run)

## Commit rules

This project follows
[Conventional Commits](https://www.conventionalcommits.org/).
A `.gitmessage` template is available at the repository root.
Write user-facing, lowercase subjects, keep them under 72 characters,
and split unrelated changes into separate atomic commits.

Key scopes: `apt`, `brew`, `mise`, `docker`, `vm`, `locale`, `ci`,
`lint`, `readme`, `docs`.

## Immediate rules

- Match the conversational language to the user's language.
- Write comments and documentation in English.
- If uncertainty blocks a safe change, stop and ask before proceeding.
- Keep changes small and atomic.
- Do not modify community documents (`CODE_OF_CONDUCT*`,
  `CONTRIBUTING*`) without explicit approval.
- Do not install GUI applications — CLI only.

## Project standards

- **Indentation**: 2 spaces
- **Line endings**: LF only
- **Trailing whitespace**: trimmed except in Markdown
- **Final newline**: always present
- **File naming**: lowercase with hyphens unless a platform convention
  requires otherwise

## Canonical reference

The full project guidance lives in
[.github/copilot-instructions.md](.github/copilot-instructions.md).
When that file uses Copilot-specific workflow names (Agent mode, Plan
mode), apply the intent using Codex's own interaction model.
