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
- Resynced: `iddVersion 0.6.0`, imported from
  [`kurone-kito/idd-skill`](https://github.com/kurone-kito/idd-skill)
  `main` at commit
  [`abd841ac0712dec83231ca77096abea67a3497b4`](https://github.com/kurone-kito/idd-skill/commit/abd841ac0712dec83231ca77096abea67a3497b4)
  (2026-08-12). `.github/instructions/lite/` remains deliberately
  excluded, unchanged reasoning from the 0.4.0 entry.
  `helperRuntime.packageSpec` is now pinned to the same commit so the
  `ephemeral-npx` runtime and the distributed instructions never drift
  apart. `.markdownlint-cli2.yaml` required a hand merge (this
  repository's file predates upstream's own copy) rather than a straight
  overwrite. Registering `idd-advisory-convergence` as a required status
  check was reconsidered and declined again.

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
- Labels: see [IDD label set](#idd-label-set) below
- Claim timing: stale `PT24H` / heartbeat `PT12H` (defaults)
- Autopilot-suitability floor: `3` (default) — no repository-specific
  reason to raise or lower the autopilot-selection floor recorded yet.
- Issue scope: `roadmap-first` (default) — Discover walks the roadmap
  path first with an orphan fallback, matching this repository's
  roadmap-driven workflow so far (#48 and its children).
- Orphan-first policy: `none` (default) — no orphan-first override is
  in effect.
- Workshop example repository: `""` (empty string, treated as unset;
  default) — this repository has not published a `docs/workshop/`, so
  the `idd-doctor` example-repository back-link check is intentionally
  skipped.
- Claude Code permission baseline: installed at `.claude/settings.json`
  (#43), adapted from the opt-in template baseline documented in
  [`docs/permissions.md`](permissions.md#claude-code-permission-baseline).
  Three deltas from that opt-in default. Two follow directly from the
  `fully_autonomous_merge` policy already recorded above: `gh pr merge`
  is allowlisted, and the `idd-merge-execute` deny entries are dropped
  so `--apply` merges are not blocked. The third is unrelated to merge
  policy: the generic `node scripts/*` / `node bin/*` allow entries are
  replaced with this repository's actual `ephemeral-npx` invocation
  form. Every other allow/deny entry, including the deliberate absence
  of any `gh api` allow, matches upstream unchanged.

This is a personal repository with a single owner and maintainer
(`kurone-kito`). The issue-author approval gate stays enabled; the owner
self-authorizes before starting work. `kurone-kito` satisfies
`owners-and-maintainers-only`, so owner-authored issues self-authorize
and the `idd:ready` label below is only needed for issues filed by
someone else. Pull-request review automation in this repository is
handled by CodeRabbit
([`.coderabbit.yaml`](../.coderabbit.yaml)); the `copilot-advisory` profile
treats such bot reviews as advisory rather than blocking.

## IDD label set

This repository had no pre-existing label taxonomy to map onto, so the
IDD label names below are the upstream defaults, adopted unchanged
(#45). Three (`roadmap`, `status:blocked-by-human`,
`status:needs-decision`) are explicitly configured under `labels.*` in
[`.github/idd/config.json`](../.github/idd/config.json); the other two
have no entry there and resolve via the distributed defaults recorded
in `docs/policy-constants.md`.

| Label | Policy key | Configured or defaulted | Consumed by |
| --- | --- | --- | --- |
| `roadmap` | `labels.roadmapLabelName` | configured | Discover roadmap-first scanning, A1.5 roadmap completion audit |
| `status:blocked-by-human` | `labels.blockedByHumanLabelName` | configured | A4.5 suitability triage, roadmap audit non-autonomous gap |
| `status:needs-decision` | `labels.needsDecisionLabelName` | configured | A4.5 suitability triage, roadmap audit |
| `idd:ready` | `approvalSignals.readyLabelName` | defaulted (key absent from `config.json`) | A3.5 issue-author approval gate |
| `status:authoring` | `issueAuthoring.authoringLabelName` | defaulted (key absent from `config.json`) | Discover authoring guard (A0-T/A0-O/A3) |

`.github/workflows/stale.yml` must exempt `roadmap`,
`status:blocked-by-human`, `status:needs-decision`, and
`status:authoring` from its `exempt-issue-labels` (#50): each marks an
issue IDD deliberately parks without activity — a roadmap stays open by
design across its whole initiative, and the three hold labels exist
precisely because a human has not acted yet. The stale bot cannot read
`.github/idd/config.json`, so the workflow keeps a literal exempt list
with a comment naming the four policy keys above it mirrors; keep both
in sync if any of these label names ever changes.

## Helper runtime (`ephemeral-npx`)

This repository has no `package.json` and no lockfile, ruling out the
`package-manager` profile, which requires a manifest to resolve against.
`vendored-node` was declined too, though it needs no manifest: it copies
a local helper bundle into the repository at import time, which would
add files to this shell-and-Terraform repository and need re-vendoring
on every upstream bump. `ephemeral-npx` avoids both costs.

- Pinned helper package spec:
  `https://codeload.github.com/kurone-kito/idd-skill/tar.gz/abd841ac0712dec83231ca77096abea67a3497b4`
  — intentionally pinned to the same commit the instruction files were
  imported from (originally in #41, resynced to this commit in #88), so
  a helper's JSON output contract can never drift away from the
  instruction step that reads it.
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
- CI-side consumer: `.github/workflows/idd-doctor.yml` (#46) resolves
  its `idd-doctor` invocation from the pinned spec above. The same
  commit SHA now has to stay in sync across four locations on a future
  resync: the two occurrences in this file (the
  [imported-snapshot line](#imported-template-snapshot) and the pinned
  spec above), `.claude/settings.json`'s permission allow-list (#43),
  and this workflow file. The workflow omits `--strict`: strict mode's
  sibling-worktree check has no observable signal in a CI checkout —
  `pull_request` runs always check out a detached commit, never a
  named `issue/*`/`roadmap-audit/*` branch, so the violation `--strict`
  guards against structurally cannot occur there. Enforcement for that
  rule stays local, via `.githooks/pre-commit`/`pre-push` and a
  developer's own `idd-doctor --strict` run.
- `.github/workflows/idd-advisory-convergence.yml` (#47) resolves its
  `idd-advisory-convergence` invocation from the same pinned spec — the
  commit SHA now has to stay in sync across five locations on a future
  resync, the four above plus this workflow file. This workflow is
  **hosted but not registered as a required check**: two GitHub
  Rulesets exist on this repository today (`gh api
  repos/{owner}/{repo}/rulesets` includes rulesets named `main` and
  `features`, both `enforcement: active`) — a maintainer-created
  addition, not one this IDD loop configured. Each enables
  `copilot_code_review`
  (`review_on_push: true`), so Copilot now reviews every push
  automatically; `main` (targeting `~DEFAULT_BRANCH`) also enables the
  `deletion` / `non_fast_forward` rules and a `pull_request` rule with
  `required_approving_review_count: 0`. Neither ruleset declares a
  `required_status_checks` rule, so `idd-advisory-convergence` still is
  not a GitHub-enforced merge gate — a maintainer who wants to enforce
  it opens Settings → Rules → Rulesets → edit `main`, enables "Require
  status checks to pass", and adds `idd-advisory-convergence` (the job
  id) to the required-checks list.
  `--assert` exits non-zero for any not-ready verdict, including the
  ordinary "Copilot has not reviewed this HEAD yet" pending case —
  GitHub Actions has no distinct non-failing "pending" state, so this
  check legitimately shows red until the advisory review converges.
  This is by design, not a failure to fix.
  The waiver escape path after `advisoryWait.convergenceDeadline` (24h
  from the HEAD commit timestamp) only exists once
  `ciGate.externalCheckWaivers.mode` is `maintainer-authorized` (not its
  default, `disabled`) and `idd-advisory-convergence` is listed under
  `ciGate.externalChecks.waivable`. **Neither precondition is met
  today**: `ciGate` now exists in `.github/idd/config.json` (added by
  #99 to trust an empty classic branch-protection read, now that this
  repository's branch protection lives in the rulesets above instead of
  the classic API), but it sets only `trustEmptyProtectionReads`;
  `externalCheckWaivers` is still unset, so both default closed. A
  maintainer who wants the escape hatch has to add both keys
  explicitly; until then, a stuck not-ready verdict
  past the 24h deadline has no waiver available, only the underlying
  advisory review actually converging. Posting a waiver comment, once
  the escape hatch is enabled, does not by itself re-run the check —
  a fresh trigger (a `pull_request` synchronize, review or
  review-comment activity, or `workflow_dispatch`) still has to fire;
  this workflow has no `push` trigger.
