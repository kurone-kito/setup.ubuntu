# Guidelines for AI Agents

Automated CLI dev-environment setup for Ubuntu 22.04+ (including WSL).
Install-only scope — configuration belongs in the
[dotfiles](https://github.com/kurone-kito/dotfiles) repository.

## Key facts

- APT packages → `cloud-init.yml`; Homebrew → `lib/Brewfile`;
  mise → `lib/mise.sh`
- Shell scripts: POSIX `sh` preferred, `set -eu`, idempotent
- Conventional Commits; scopes: `apt`, `brew`, `mise`, `docker`,
  `vm`, `locale`, `ci`, `lint`, `readme`, `docs`
- 2-space indent, LF only, lowercase-hyphen filenames
- No GUI apps — CLI environment only

## Canonical reference

The full project guidance lives in
[.github/copilot-instructions.md](.github/copilot-instructions.md).
