# IDD policy decisions

This project adopts the Issue-Driven Development (IDD) workflow from the
[idd-skill](https://github.com/kurone-kito/idd-skill) template. This file
records the onboarding decisions and must stay aligned with
[`.github/idd/config.json`](../.github/idd/config.json) whenever a value
changes.

## Imported template snapshot

- Initial import: `iddVersion 0.3.0` on 2026-06-18 (`d81554b`).
- Resynced: `iddVersion 0.4.0`, imported from
  [`kurone-kito/idd-skill`](https://github.com/kurone-kito/idd-skill)
  `main` at commit
  [`4e8c7043edcb00dd8447dee83e7a17e5b2604d5d`](https://github.com/kurone-kito/idd-skill/commit/4e8c7043edcb00dd8447dee83e7a17e5b2604d5d)
  (2026-07-24). `.github/instructions/lite/` is deliberately excluded —
  it targets the lightweight local-model tier this repository does not
  use.

## Project values

- `REPO_NAME`: `setup.ubuntu`
- `PROJECT_MARKER_PREFIX`: `setup-ubuntu`
- `TRUSTED_MARKER_ACTOR`: `kurone-kito`
- `INSTALL_DEPS_COMMAND`: `true` (no dependency manifest in this repository)

Validate command strings (kept in sync with
[`.github/idd/config.json`](../.github/idd/config.json)):

```sh
# fix-validate
npx -y markdownlint-cli2 --fix "**/*.md" && npx -y markdownlint-cli2 "**/*.md"

# pre-push-validate
npx -y markdownlint-cli2 "**/*.md" && npx -y cspell lint "**" --no-progress

# post-fix-validate
npx -y markdownlint-cli2 --fix "**/*.md" && npx -y markdownlint-cli2 "**/*.md" && npx -y cspell lint "**" --no-progress
```

These commands run `markdownlint` and `cspell`, matching the checks that
most IDD issues exercise. The `lint` workflow
([`.github/workflows/lint.yml`](../.github/workflows/lint.yml)) additionally
runs `shellcheck` on the shell scripts; it is kept out of the local validate
commands above (which target the markdown and text edits IDD issues usually
make). Run `shellcheck setup nuke lib/*.sh` directly when changing shell
scripts.

## Policy decisions

- Merge policy: `fully_autonomous_merge`
- Credential scope: narrowest profile matching the merge policy
- PR review profile: `copilot-advisory` (default)
- Review-thread resolution: `fast-agent-resolve` (default)
- Critique-loop profile: shipped defaults (see `docs/policy-constants.md`)
- CI wait policy: `PT30M` / `PT10M` / `rerun-once` (defaults)
- Issue-author approval gate: enabled (default)
- Maintainer approval actors: `owners-and-maintainers-only` (default)
- Issue-authoring companion: installed at
  `.claude/skills/issue-authoring/` (relocated from the upstream
  source layout by #44; a future template resync must copy the
  upstream bundle to that same installed path, not the pre-#44
  location)
- Helper runtime profile: `ephemeral-npx` (see
  [Helper runtime](#helper-runtime-ephemeral-npx) below)
- Advisory bot logins: `copilot-pull-request-reviewer[bot]`,
  `coderabbitai[bot]`, `chatgpt-codex-connector[bot]`
- Advisory-wait convergence scope: `idd-claimed` (see
  [Helper runtime](#helper-runtime-ephemeral-npx) below for the
  rationale)
- Worktree guard: `enabled: true` (see
  [Helper runtime](#helper-runtime-ephemeral-npx) below for the
  activation step)
- Labels: roadmap `roadmap`, blocked-by-human
  `status:blocked-by-human`, needs-decision `status:needs-decision`
- Claim timing: stale `PT24H` / heartbeat `PT12H` (defaults)

This is a personal repository with a single owner and maintainer
(`kurone-kito`). The issue-author approval gate stays enabled; the owner
self-authorizes before starting work. Pull-request review automation in
this repository is handled by CodeRabbit
([`.coderabbit.yaml`](../.coderabbit.yaml)); the `copilot-advisory` profile
treats such bot reviews as advisory rather than blocking.

## Helper runtime (`ephemeral-npx`)

This repository has no `package.json` and no lockfile, ruling out the
`package-manager` profile, which requires a manifest to resolve against.
`vendored-node` was declined too, though it needs no manifest: it copies
a local helper bundle into the repository at import time, which would
add files to this shell-and-Terraform repository and need re-vendoring
on every upstream bump. `ephemeral-npx` avoids both costs.

- Pinned helper package spec:
  `https://codeload.github.com/kurone-kito/idd-skill/tar.gz/4e8c7043edcb00dd8447dee83e7a17e5b2604d5d`
  — intentionally pinned to the same commit the instruction files were
  imported from in #41, so a helper's JSON output contract can never
  drift away from the instruction step that reads it.
- Canonical invocation form: `npx --yes --package <pinned-spec>
  idd-<helper>`. Under this profile the `idd-*` bin facade is the
  authoritative surface, not `node scripts/*.mjs`.
- A helper failure is a stop-and-ask condition, never a silent
  fallback to prose.
- One-time activation for the worktree guard:

  ```sh
  git config core.hooksPath .githooks && chmod +x .githooks/pre-commit .githooks/pre-push
  ```

  `core.hooksPath` is uncommitted git config, not repository content,
  so every fresh clone or ephemeral agent environment must rerun this
  step. This plain (non-`--worktree`-scoped) form writes to the
  repository's shared config, so it applies across every worktree of a
  given clone rather than to just one — this is the correct scope for
  this guard: `.githooks/_idd-worktree-guard.sh` only ever blocks a
  commit or push made from the *primary* worktree while `HEAD` sits on
  an `issue/*` or `roadmap-audit/*` branch, so it is a guaranteed no-op
  in every sibling implementation worktree.
- Why `advisoryWait.convergenceScope` is `idd-claimed` rather than the
  `all-prs` default: this repository merges Dependabot pull requests,
  which carry no IDD claim and would otherwise be swept into an
  advisory-convergence gate they can never satisfy on their own.
- `advisoryWait.primaryBotLogin` and `advisoryWait.secondaryBotLogin`
  are deliberately left unset: Copilot is tracked without a pinned
  login, and CodeRabbit reviews through an app install rather than as
  a requestable reviewer, so it cannot satisfy the once-per-HEAD
  secondary-bot contract.
