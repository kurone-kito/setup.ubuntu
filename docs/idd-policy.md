# IDD policy decisions

This project adopts the Issue-Driven Development (IDD) workflow from the
[idd-skill](https://github.com/kurone-kito/idd-skill) template. This file
records the onboarding decisions and must stay aligned with
[`.github/idd/config.json`](../.github/idd/config.json) whenever a value
changes.

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
- Issue-authoring companion: installed (`skills/issue-authoring/`)
- Helper runtime profile: `instructions-only`
- Claim timing: stale `PT24H` / heartbeat `PT12H` (defaults)

This is a personal repository with a single owner and maintainer
(`kurone-kito`). The issue-author approval gate stays enabled; the owner
self-authorizes before starting work. Pull-request review automation in
this repository is handled by CodeRabbit
([`.coderabbit.yaml`](../.coderabbit.yaml)); the `copilot-advisory` profile
treats such bot reviews as advisory rather than blocking.
