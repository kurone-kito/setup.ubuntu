---
type: reference
title: IDD policy decisions
description: Records this repository's onboarding decisions for the imported IDD workflow.
tags: [idd-policy, onboarding]
---

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
- Resynced: `iddVersion 0.7.0`, imported from
  [`kurone-kito/idd-skill`](https://github.com/kurone-kito/idd-skill)
  `main` at commit
  [`f51a8bb73a47452eff5799e8a27251b660ba4ae0`](https://github.com/kurone-kito/idd-skill/commit/f51a8bb73a47452eff5799e8a27251b660ba4ae0)
  (2026-08-19). `.github/instructions/lite/` remains deliberately
  excluded, unchanged reasoning from the 0.4.0/0.6.0 entries.
  `helperRuntime.packageSpec` is re-pinned to the same commit (#119),
  keeping the `ephemeral-npx` runtime and the distributed instructions
  in sync; this file's own "Pinned helper package spec" line below
  moves to match. The two new optional policy fields this release
  added (`authoringLanguage`, `critiqueLoop.delegate`) were considered
  and not adopted — no product/design decision favors either yet.
  Registering `idd-advisory-convergence` as a required status check
  remains unchanged this cycle; see #114, deferred until this resync's
  wall-clock-deadline polling fix is confirmed live. The imported
  workflow surface shipped 2 of the 3 upstream files
  (`idd-advisory-convergence.yml`, `post-merge-cleanup.yml`); the third
  (`idd-advisory-convergence-comment.yml`) split out to #128, blocked
  on an upstream gap — no `ephemeral-npx`-reachable bin export for
  `scripts/review-comment-origin.mjs` exists in `f51a8bb7`.
- Resynced: `iddVersion 0.11.0`, imported from
  [`kurone-kito/idd-skill`](https://github.com/kurone-kito/idd-skill)
  `main` at commit
  [`1f90787ebf4021673ce6e5eb69741df331fd2037`](https://github.com/kurone-kito/idd-skill/commit/1f90787ebf4021673ce6e5eb69741df331fd2037)
  (2026-09-12), carrying this repository through the `0.8.0`, `0.9.0`,
  `0.10.0`, and `0.11.0` releases (roadmap #139, re-scoped in place from
  an initially-drafted `0.9.0` target on 2026-09-12, before any of its
  tracks were claimed or started, to avoid resyncing twice back to back
  through the releases that shipped in the meantime).
  `.github/instructions/lite/` remains deliberately excluded, unchanged
  reasoning from prior entries. `mergePolicyAck: "fully_autonomous_merge"`
  reaffirms the existing `mergePolicy` value now that upstream's own
  distributed default flipped to `human_merge` — a pure diagnostics
  field, no merge-authority change (#140). Adopted this cycle, all
  settled via an authoring-time hearing (three) and a 2026-09-12
  re-scoping hearing (four more) — not open questions:
  - `critiqueLoop.delegate` in `combined` mode, using this repository's
    own `pre-push-validate` command — `fallback` mode was considered
    and rejected because a lint-only delegate would skip the per-agent
    critique pass on almost every clean run, a review-quality
    regression rather than an addition (#143). See
    [Policy decisions](#policy-decisions) below (supersedes the
    "shipped defaults" position recorded at `0.7.0`).
  - `providerOutage` declaration adopted in full, including the
    `ciGate.externalCheckWaivers`/`externalChecks.waivable`
    preconditions it depends on — this closes the "Neither
    precondition is met today" gap the `0.7.0` entry recorded as
    deliberately left open (#143). Declaration target: #158. See
    [Helper runtime](#helper-runtime-ephemeral-npx) below for the
    updated precondition state.
  - `authoringLanguage: "en"` adopted, previously left unadopted twice
    — this repository's global Claude Code instructions direct English
    documentation/comments regardless of a session's own conversational
    language, and this repository's issue/PR history is entirely in
    English already (#143).
  - `upstreamEscalation.enabled: true` adopted — this repository has
    real precedent (#128, #130) finding genuine `idd-skill` upstream
    defects during resyncs; auto-filing a `status:upstream-candidate`
    issue on a high-confidence find removes the dependency on manual
    noticing (#143). Never set in `kurone-kito/idd-skill` itself — the
    adopter-only condition it gates cannot occur there.
  - `developmentBranch: "main"` + `worktreeGuard.refuseBaseBranchCommits:
    true` adopted together — hardens the existing
    `worktreeGuard.enabled: true` guard to also refuse a primary-worktree
    commit/push made directly on the base branch, not only on an
    `issue/*`/`roadmap-audit/*` branch (#143). This also required
    resyncing `.githooks/_idd-worktree-guard.sh` itself (out of sync
    with upstream's own `refuseBaseBranchCommits` support, a gap PR
    #159's review caught) — see
    [Helper runtime](#helper-runtime-ephemeral-npx) below.
  - `labels.untrustedLabelerLogins: ["coderabbitai[bot]"]` adopted,
    backed by a hand-written `.github/workflows/strip-untrusted-labels.yml`
    guard (the manual recipe, not the `idd-onboard --substitute`
    generated path, since that generator is not a cataloged
    `ephemeral-npx` helper command) — guards this repository's three
    configured IDD labels against CodeRabbit's issue-enrichment
    auto-labeling (#143). See [IDD label set](#idd-label-set) below.
  - The optional `idd-spec-audit` companion skill is adopted, installed
    at `.claude/skills/idd-spec-audit/` mirroring the `issue-authoring`
    installed-path precedent (#150). See
    [Policy decisions](#policy-decisions) below.
  - `provider`, `advisoryWait.secondaryQuietWindow`,
    `advisoryWait.providerOutage.terminalWindow`, `advisoryConvergence.*`,
    `localValidationEvidence.maxAge`, `providerHealth.*`,
    `discover.milestoneScope`, and `critiqueLoop.telemetryHook` were all
    considered and intentionally not adopted this cycle — each already
    matches this repository's actual behavior, or has no adopted use
    case yet.
  - Registering `idd-advisory-convergence` as a required GitHub-ruleset
    status check was reconsidered again this cycle and declined again
    — unchanged from the `0.7.0` entry's position; see
    [Helper runtime](#helper-runtime-ephemeral-npx) below.
  - The imported workflow surface now ships all three files:
    `idd-advisory-convergence.yml`, `post-merge-cleanup.yml` (both
    resynced, the former gaining the new
    `idd-advisory-convergence-self-waiver` job), and
    `idd-advisory-convergence-comment.yml` (newly importable — upstream
    now exports an `idd-review-comment-origin` bin entry, resolving the
    gap #128 tracked; closed via #152). #130's tracked upstream gap
    (the post-merge-cleanup evidence-discard logic only checking the
    prior comment's recorded status, not the current run's own status)
    was fixed upstream and picked up automatically via this resync's
    verbatim file copy — no local patch was needed; resolved via #152.
  - The `issue-authoring` skill bundle was resynced in full (#142),
    surfacing two new structural preconditions this repository did not
    yet satisfy: no configured `issueAuthoring.journalIssue` for
    standalone issue authoring, and no `ephemeral-npx` capability for
    the new capability-checked issue-publication command. Tracked as
    `status:needs-decision` in #157; decided live with the maintainer
    and implemented in #164 — `issueAuthoring.journalIssue` is now
    configured, and atomic-label issue creation is covered by a local
    `gh issue create --label` fallback. The remaining
    publication-token / journal half of that fallback is now closed
    (#180) — see [Policy decisions](#policy-decisions) below.
- Resynced: `iddVersion 0.12.0`, imported from
  [`kurone-kito/idd-skill`](https://github.com/kurone-kito/idd-skill)
  `main` at commit
  [`11105d705820e50be0a14fcc174587abbaf62b30`](https://github.com/kurone-kito/idd-skill/commit/11105d705820e50be0a14fcc174587abbaf62b30)
  (2026-09-18), via roadmap #175. Children: #176 (pin), #177
  (corpus), #178 (workflows), #179 (skills), #180 (publication
  protocol), #181 (this finalize). `.github/instructions/lite/`
  remains deliberately excluded, unchanged reasoning from prior
  entries. 2026-09-18 maintainer hearing, recorded here against
  shipped sibling outcomes — not open questions:
  - `critiqueLoop.deferAfterRounds` inherits the new upstream
    default of 12 (was 15). The key is intentionally unset in
    `.github/idd/config.json` so the distributed default applies
    (#176 left it absent; this finalize records the hearing).
  - Cursor remains docs-only: Cursor CLI is documented on the
    `AGENTS.md` path inside imported `docs/idd-workflow.md` and
    `docs/onboarding/agent-entry-and-verification.md`. `CURSOR.md`
    is not added (#177).
  - Hosted workflows were hand-merged, not template-pasted (#178):
    `idd-advisory-convergence.yml` stays this repository's
    `ephemeral-npx` rewrite (0.12.0 self-waiver scopes and evidence
    rules ported in; both hardcoded `packageSpec` SHAs bumped);
    `post-merge-cleanup.yml` took the 0.12.0 `workflow_dispatch`
    trust-gap fixes while keeping `ubuntu-slim` and action SHA
    pins; `idd-advisory-convergence-comment.yml` had no 0.12.0
    logic delta and was left untouched.
  - Profile-selected helper invocation forms were kept in
    `idd-overview-appendix.instructions.md` (provider-outage park)
    and `idd-suitability.instructions.md` (high-confidence close)
    rather than taking upstream 0.12.0's hardcoded
    `node scripts/*.mjs` paths (#177).
  - Companion skills were resynced in full at `.claude/skills/`
    (#179), keeping the installed-path precedent (#44, #150).
  - `critiqueLoop.telemetryHook` remains unset. Registering
    `idd-advisory-convergence` as a required GitHub-ruleset status
    check was declined again. `ONBOARDING.md` is still not
    imported (docs deep-link the upstream file). `idd-template/`
    and `scripts/` are still not copied. All reaffirmed from the
    0.11.0 hearing on 2026-09-18.
  - The publication-token / journal protocol is closed by the
    protocol child (#180); see that child's Policy decisions
    bullet. This finalize does not rewrite it.
- Resynced: `iddVersion 0.14.0`, imported from
  [`kurone-kito/idd-skill`](https://github.com/kurone-kito/idd-skill)
  tag `v0.14.0`, which peels to commit
  [`ae16f497434a5023dfaa28f965fc2af92ebf055d`](https://github.com/kurone-kito/idd-skill/commit/ae16f497434a5023dfaa28f965fc2af92ebf055d)
  (2026-10-03), via roadmap #192. Children: #193 (config pin
  and dogfooding keys), #194 (template import, including
  lite), #195 (issue-authoring companion), #197 (hosted
  workflows), and #196 (this note). `.github/instructions/lite/`
  is imported now. The "deliberately excluded" sentences in
  earlier snapshot entries stay historical records of those
  resyncs. This entry records the shipped sibling outcomes,
  not open questions. `helperRuntime.packageSpec` is re-pinned
  to that same commit (#193). The profile stays
  `ephemeral-npx`: no package-manager runtime and no vendored
  `scripts/` bundle. `workshop.exampleRepository` stays `""`
  because this repository publishes no `docs/workshop/`. The
  current [Policy decisions](#policy-decisions) and
  [Helper runtime](#helper-runtime-ephemeral-npx) sections
  below are the adopted settings. They supersede the 0.12.0
  hearing points that left `critiqueLoop.deferAfterRounds`
  unset so the default of 12 would apply, and that left
  `critiqueLoop.telemetryHook` unset.

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

- Merge policy: `fully_autonomous_merge`. `mergePolicyAck:
  "fully_autonomous_merge"` reaffirms this value (added at `0.11.0`,
  #140) now that upstream's own distributed default flipped to
  `human_merge` — a pure diagnostics field, no merge-authority change.
- Credential scope: narrowest profile matching the merge policy
- PR review profile: `copilot-advisory` (default)
- Review-thread resolution: `fast-agent-resolve` (default)
- Critique-loop delegate: `combined` mode, using this repository's own
  `pre-push-validate` command (markdownlint + cspell) — C1's per-agent
  critique runs alongside this delegate on every pass, findings
  unioned. Adopted at `0.11.0` (#143); `fallback` mode was considered
  and rejected because it would skip the per-agent pass whenever the
  delegate merely exits 0, a review-quality regression rather than an
  addition.
- Critique-loop deferral: `critiqueLoop.deferAfterRounds` is `5`
  and `critiqueLoop.deferByUrgency` is `severity-tiered`, both set
  in `.github/idd/config.json` (#193). This supersedes the 0.12.0
  hearing that left `deferAfterRounds` unset so the distributed
  default of 12 would apply (#181).
- Critique-loop telemetry: `critiqueLoop.telemetryHook.command` is
  `idd-critique-telemetry` (#193). The hook is fire-and-forget. A
  missing command does not gate an IDD phase.
- Forced handoff: `forcedHandoff.mode` is `human-gated` and
  `forcedHandoff.authorityPolicy` is `owners-and-maintainers-only`
  (#193).
- GitHub API client: `githubApi.readCache.enabled` is `true`, and
  `githubApi.loadControl` is enabled with `maxConcurrent` `4`
  (#193).
- Discover selection desync: `discover.selectionDesync` is
  `session-offset` (#193).
- Advisory-wait deadline: `advisoryWait.convergenceDeadline` is
  `PT9H`, measured from when GitHub first recorded the HEAD (its
  earliest check suite), not from the commit timestamp (#193).
  The imported prose does not all state that clock. The narrative
  in `docs/policy-constants.md` still measures this deadline from
  the HEAD commit timestamp and does not name a duration there.
  Its defaults table lists the distributed duration as 24h and
  already measures that duration from the earliest check suite
  (#3253). This repository's duration is `PT9H`, not that 24h
  default. `docs/onboarding/optional-host-setup.md`
  (waiver-after-deadline) and `docs/idd-helper-scripts.md`
  (deadlock / deadline policy) still say the default is 24h from
  the HEAD commit timestamp. Those two sentences are not operative.
  The helper at `ae16f497434a5023dfaa28f965fc2af92ebf055d` measures
  elapsed time from `headObservedAt`; `headCommittedAt` is
  informational only. A later import that updates the stale
  sentences should replace this note.
  `convergenceScope` stays `idd-claimed`. No secondary-bot quiet
  window is configured.
- External-check waivers: `ciGate.externalCheckWaivers.mode` stays
  `maintainer-authorized`. #193 made `authorityPolicy`
  `owners-and-maintainers-only` and `maxValidity` `PT24H` explicit.
  `PT24H` is the waiver lifetime, not the convergence deadline.
  The self-waiver bootstrap expiry is a separate clock: the HEAD
  commit timestamp plus a fixed `PT24H`, clamped to `maxValidity`
  when that maximum is shorter. If that HEAD-anchored result is
  already non-future (a stale HEAD, such as a `reopened` trigger
  with no new commit), the window anchors on the current time
  instead. `externalChecks.waivable` lists
  `idd-advisory-convergence` with `matchMode` `exact`.
- Lite instructions: `.github/instructions/lite/` is part of the
  imported surface as of #194 (11 files). Earlier snapshot entries
  that say it was deliberately excluded describe those earlier
  resyncs.
- Issue-authoring companion (#195): the four installed
  `.claude/skills/issue-authoring/` files match v0.14.0 except the
  three `idd-authoring-set-members` invocation sites, which use
  this repository's immutable `ephemeral-npx` package spec.
  Installed `idd-spec-audit` was compared to that commit and left
  unchanged.
- Hosted workflows (#197): the gate, comment companion, probe, and
  post-merge cleanup workflows call helpers only through the
  v0.14.0 `ephemeral-npx` pin. The probe cites commit
  `ae16f497434a5023dfaa28f965fc2af92ebf055d` in its header and does
  not fetch the tarball. They do not use pnpm, a mutable branch, a
  vendored bundle, or a secondary-bot wait. Third-party actions
  stay pinned to
  `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1`
  (`v7.0.1`) and
  `actions/setup-node@820762786026740c76f36085b0efc47a31fe5020`
  (`v7.0.0`) on the gate, the comment companion, and post-merge
  cleanup. The gate also pins
  `actions/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a`
  (`v7.0.1`). Node is `24.x` wherever `setup-node` is used. The
  probe uses no third-party action. Runners: the gate uses
  `inputs.runner || vars.CI_RUNNER_LABEL || ubuntu-slim`; the
  comment companion and the probe use
  `vars.CI_RUNNER_LABEL || ubuntu-slim`; post-merge cleanup uses
  `ubuntu-slim`. Triggers: the gate uses `pull_request` and
  `pull_request_target` (`opened`, `reopened`, `synchronize`),
  plus `workflow_dispatch` and `workflow_call`. The comment
  companion uses `pull_request_review` (`submitted`),
  `pull_request_review_comment` (`created`, `edited`, `deleted`),
  and `issue_comment` (`created`). A submitted
  `pull_request_review` from a non-bot actor reruns the gate
  regardless of comment classification, skips debounce, and passes
  `--refresh-latest --apply`. A submission by the primary bot does
  not: GitHub gates that bot-triggered run to `action_required`
  before any job starts, so the companion never reaches the rerun
  step. The required check then refreshes on the next qualifying
  non-bot trigger: a push, another non-bot `pull_request_review`
  (ordinary prose still counts on that submission), or an
  IDD-originated review-thread reply or issue comment. Ordinary
  prose on a review comment or an issue comment does not qualify.
  A fork pull
  request's review token is read-only, so the rerun step runs and
  `gh run rerun` fails with a 403. A review comment or an issue
  comment reruns only when it is IDD-originated and debounce does
  not skip, using plain `--apply`. The probe uses `issue_comment`
  (`created`). Post-merge
  cleanup uses `pull_request_target` (`closed`) and
  `workflow_dispatch`. Permissions stay least-privilege. The
  gate default is contents, issues, and pull-requests `read`;
  its verdict job adds `actions: read`; its self-waiver job is
  contents `read`, pull-requests `write`, issues `write`, checks
  `read`, and statuses `read`. That job's `if` is
  `pull_request_target` only. It posts
  `self-referential-bootstrap-auto` only for a same-repository
  pull request whose diff touches `.github/idd/config.json`,
  `.github/workflows/idd-advisory-convergence.yml`, or
  `.github/workflows/idd-advisory-convergence-comment.yml`, and
  only when the auto-waiver guard accepts that pull request.
  This repository sets `advisoryWait.convergenceScope` to
  `idd-claimed`. A pull request with no claim-marker history is
  `not_applicable` and is not eligible. Ambiguous closing
  references, or claim-marker history with no active claim, are
  `indeterminate` and are not eligible. A branch mismatch against
  an active claim stays eligible. The posting helper also refuses
  when linked claim candidates are ambiguous. The
  comment companion is those
  three read scopes plus `actions: write`. The probe workflow
  `permissions` block is empty, and its job is contents, issues,
  pull-requests, actions, checks, and statuses `read`. Post-merge
  cleanup is contents `read`, issues `write`, and pull-requests
  `write`. `idd-advisory-convergence` stays hosted and is not a
  required status check. See
  [Helper runtime](#helper-runtime-ephemeral-npx) for the ruleset
  step that adds it beside the checks `main` already requires.
- Lint overlay retained by #194: the project's cspell vocabulary
  and the `.terraform/**/*` markdown-lint exclusion stay local.
  Validate commands stay the markdownlint-cli2 and cspell rows in
  [Project values](#project-values).
- CI wait policy: `PT30M` / `PT10M` / `rerun-once` (defaults)
- Issue-author approval gate: enabled (default)
- Maintainer approval actors: `owners-and-maintainers-only` (default)
- Issue-authoring companion: installed at
  `.claude/skills/issue-authoring/` (relocated from the upstream
  source layout by #44; a future template resync must copy the
  upstream bundle to that same installed path, not the pre-#44
  location)
- `idd-spec-audit` companion (new in `0.10.0`, same distribution
  pattern as `issue-authoring`): installed at
  `.claude/skills/idd-spec-audit/`, mirroring the `issue-authoring`
  installed-path precedent above (#150).
- `issueAuthoring.journalIssue`: `kurone-kito/setup.ubuntu#163`, a
  dedicated durable comment-only issue created for this purpose —
  decided with the maintainer live (#157, #164), kept separate from
  #158 (`providerOutage.declarationTarget`), a different concern.
  Standalone (non-roadmap-anchored) issue authoring stays allowed, not
  disabled.
- Capability-checked create-with-label publication command
  (`.claude/skills/issue-authoring/references/contract.md`): keep
  `gh issue create --label <authoringLabelName>` as the atomic
  create-with-label operation (permanent local substitute; still no
  upstream `idd-issue-create` bin). Publication token,
  publication-intent journal writes, owner markers, and the
  hide-on-supersede sweep follow the installed
  `.claude/skills/issue-authoring/references/` contract. Invoke
  `idd-post-idd-marker` and `idd-sweep-authoring-markers` as
  `npx --yes --package <helperRuntime.packageSpec> <idd-bin>`
  (`ephemeral-npx`; pin source of truth: `.github/idd/config.json`).
  Journal: `kurone-kito/setup.ubuntu#163`. `scripts/` is not added;
  `helperRuntime.profile` stays `ephemeral-npx`.
- `authoringLanguage: "en"` — pinned explicitly at `0.11.0` (#143),
  previously left unadopted twice. This repository's global Claude
  Code instructions direct English documentation/comments regardless
  of a session's own conversational language, and this repository's
  issue/PR history is entirely in English already.
- `upstreamEscalation.enabled: true` — adopted at `0.11.0` (#143). This
  repository has real precedent (#128, #130) finding genuine
  `idd-skill` upstream defects during resyncs; auto-filing a
  `status:upstream-candidate` issue on a high-confidence find removes
  the dependency on manual noticing.
- `providerOutage` declaration: adopted in full at `0.11.0` (#143),
  including its `ciGate.externalCheckWaivers`/`externalChecks.waivable`
  preconditions — see
  [Helper runtime](#helper-runtime-ephemeral-npx) below. Declaration
  target: #158, a durable comment-only holding issue.
- `developmentBranch`: `main`. `worktreeGuard.refuseBaseBranchCommits`:
  `true` — both adopted together at `0.11.0` (#143); see
  [Helper runtime](#helper-runtime-ephemeral-npx) below for the local
  hook enforcement this required.
- `.github/instructions/idd-roadmap-audit.instructions.md`'s
  contract-path reference intentionally points at that same installed
  `.claude/skills/issue-authoring/references/contract.md` location,
  not upstream `idd-template/`'s generic
  `skills/issue-authoring/references/contract.md` example path (#125).
  This is a **permanent, intentional divergence** from upstream — a
  future template resync must not "fix" it back to the literal
  upstream path. That same file's `{{PROJECT_MARKER_PREFIX}}` token
  (an installed instruction file, not reusable template
  documentation) is unrelated: it resolves to the literal prefix
  `setup-ubuntu`, used as `setup-ubuntu-roadmap-id`, the same ordinary
  substitution as every other installed instruction file — not a
  second divergence. This does not extend to every
  `{{PROJECT_MARKER_PREFIX}}` occurrence repository-wide —
  reusable template documentation such as
  `docs/onboarding/placeholders.md` and `docs/customization.md`
  deliberately keeps the literal placeholder as reference text and
  must stay unsubstituted.
- Helper runtime profile: `ephemeral-npx` (see
  [Helper runtime](#helper-runtime-ephemeral-npx) below)
- Advisory bot logins: `copilot-pull-request-reviewer[bot]` only.
  `coderabbitai[bot]` and `chatgpt-codex-connector[bot]` were dropped
  2026-08-19 (#115) — across PRs #111-#113 both only ever posted
  structural non-review notices (Codex: account-level usage-limit
  exhaustion; CodeRabbit: this repository's star count below its
  10-star automatic-review threshold), never a real review. Re-add
  either login via a follow-up issue if the underlying condition
  clears.
- Advisory-wait convergence scope: `idd-claimed` (see
  [Helper runtime](#helper-runtime-ephemeral-npx) below for the
  rationale)
- Worktree guard: `enabled: true`, `refuseBaseBranchCommits: true`
  (the latter added at `0.11.0`, #143 — see
  [Helper runtime](#helper-runtime-ephemeral-npx) below for the
  activation step and the local hook enforcement it required)
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
  skipped. The key is present in `.github/idd/config.json`. #193 left
  the value empty on purpose at the v0.14.0 pin.
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

`labels.untrustedLabelerLogins: ["coderabbitai[bot]"]` (added at
`0.11.0`, #143): CodeRabbit's issue-enrichment auto-labeling is active
or will be shortly in this repository, and it can apply any of the
three configured labels above to an ordinary issue on its own
judgment, silently dropping it from execution candidates or parking it
behind a hold. `.github/workflows/strip-untrusted-labels.yml` guards
against this — hand-written from upstream's manual recipe
(`docs/customization.md`'s "Fallback: manual recipe" subsection)
rather than the `idd-onboard --substitute` generated path, since that
generator is not a cataloged `ephemeral-npx` helper command. Scope is
the three base labels only; the optional
`issueAuthoring.authoringLabelName` extension was considered and left
out — no observed history of the labeler touching that label.

## Helper runtime (`ephemeral-npx`)

This repository has no `package.json` and no lockfile, ruling out the
`package-manager` profile, which requires a manifest to resolve against.
`vendored-node` was declined too, though it needs no manifest: it copies
a local helper bundle into the repository at import time, which would
add files to this shell-and-Terraform repository and need re-vendoring
on every upstream bump. `ephemeral-npx` avoids both costs.

- Pinned helper package spec:
  `https://codeload.github.com/kurone-kito/idd-skill/tar.gz/ae16f497434a5023dfaa28f965fc2af92ebf055d`
  — intentionally pinned to the same commit the instruction files were
  imported from (originally in #41, resynced in #88, resynced to
  `f51a8bb7` in #119, resynced to `1f90787e` in #140, resynced to
  `11105d70` in #176, resynced to `ae16f497` in #193), so a helper's
  JSON output contract can never drift away from the instruction step
  that reads it.
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
  commit or push made from the *primary* worktree, so it is a
  guaranteed no-op in every sibling implementation worktree. Until
  `0.11.0`, the guard only blocked `HEAD` sitting on an `issue/*` or
  `roadmap-audit/*` branch. With `worktreeGuard.refuseBaseBranchCommits:
  true` and `developmentBranch: "main"` now both set (#143), it also
  blocks a primary-worktree commit/push made directly on `main` — this
  repository's local hook copy had drifted from upstream's `#2801`
  patch and needed a verbatim resync of the hook file itself to pick up
  this check (the config keys alone changed nothing locally until that
  resync landed, per PR #159's review).
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
  its `idd-doctor` invocation from the pinned spec above. The workflow
  omits `--strict`: strict mode's sibling-worktree check has no
  observable signal in a CI checkout — `pull_request` runs always
  check out a detached commit, never a named `issue/*` or
  `roadmap-audit/*` branch, so the violation `--strict` guards
  against structurally cannot occur there. Enforcement for that rule
  stays local, via `.githooks/pre-commit` / `pre-push` and a
  developer's own `idd-doctor --strict` run.
- On the next pin bump, move every literal reference to commit
  `ae16f497434a5023dfaa28f965fc2af92ebf055d` together. Helper archive
  invocations (`tar.gz/` plus that commit) are
  `.github/idd/config.json`, `.claude/settings.json`'s permission
  allow-list, `idd-doctor.yml`, `idd-advisory-convergence.yml` (two
  commands), `idd-advisory-convergence-comment.yml`,
  `post-merge-cleanup.yml`, the three `idd-authoring-set-members`
  sites under `.claude/skills/issue-authoring/references/`, the
  pinned-spec line above, and the imported instruction examples that
  embed that spec, including the lite files. The same commit is also
  an immutable source link, not a tarball fetch, in this file's
  v0.14.0 snapshot bullet, `docs/getting-started.md`,
  `docs/onboarding/agent-entry-and-verification.md`,
  `docs/onboarding/issue-mediated-bootstrap.md`,
  `docs/onboarding/optional-host-setup.md`,
  `docs/onboarding/project-tuning.md`, `profiles/README.md`, and the
  header comment of `idd-advisory-convergence-probe.yml`, the header
  comment of `.github/workflows/post-merge-cleanup.yml` (separate
  from that file's `tar.gz/` invocation above), and the
  hosted-workflows bullet in this file, which repeats the full
  commit when it names the probe header. The 0.12.0
  snapshot's commit URL for `11105d70` stays as the history of that
  resync. It is not an active archive pin.
- `.github/workflows/idd-advisory-convergence.yml` (#47, ported in
  #197) resolves its `idd-advisory-convergence` invocation from the
  same pinned spec. This workflow is **hosted but not registered as
  a required check**. Two GitHub Rulesets exist (`main` and
  `features`, both `enforcement: active`) — a maintainer-created
  addition, not one this IDD loop configured. Both enable
  `copilot_code_review` (`review_on_push: true`), so Copilot reviews
  every push automatically. Ruleset `main` (id `20748430`, targeting
  `~DEFAULT_BRANCH`) also enables `deletion`, `non_fast_forward`, and
  a `pull_request` rule with `required_approving_review_count: 0`,
  and it requires status checks `idd-doctor` and `lint` (observed
  2026-10-07). Ruleset `features` (id `20748438`) has no required
  status checks. `idd-advisory-convergence` is on neither required
  list, so it is still not a GitHub-enforced merge gate. A maintainer
  who wants to enforce it edits ruleset `main` and adds
  `idd-advisory-convergence` (the job id) beside the existing
  `idd-doctor` and `lint` contexts. Do not drop those two, and do not
  enable the required-check rule as if it were absent: it is already
  on.
  `--assert` exits non-zero for any not-ready verdict, including the
  ordinary "Copilot has not reviewed this HEAD yet" pending case —
  GitHub Actions has no distinct non-failing "pending" state, so this
  check legitimately shows red until the advisory review converges.
  This is by design, not a failure to fix.
  The waiver escape path after `advisoryWait.convergenceDeadline`
  (`PT9H`, measured from when GitHub first recorded the HEAD — its
  earliest check suite — not from the commit timestamp; imported
  sentences that still measure 24h from the commit timestamp are
  not operative, as the advisory-wait deadline bullet records) only exists
  once `ciGate.externalCheckWaivers.mode` is `maintainer-authorized`
  (not its default, `disabled`) and `idd-advisory-convergence` is
  listed under `ciGate.externalChecks.waivable`. **Both
  preconditions are now met** (adopted at `0.11.0`, #143 — previously
  neither was, per the `0.7.0` entry above): `ciGate` sets
  `trustEmptyProtectionReads: true` (#99, unchanged),
  `externalCheckWaivers.mode: "maintainer-authorized"`, and
  `externalChecks.waivable` lists `idd-advisory-convergence`. #193
  also made `authorityPolicy` `owners-and-maintainers-only`,
  `maxValidity` `PT24H`, and `matchMode` `exact` explicit.
  `maxValidity` is the waiver lifetime. The self-waiver bootstrap
  expiry is a different clock: the HEAD commit timestamp plus a
  fixed `PT24H`, clamped to `maxValidity` when that maximum is
  shorter. If that HEAD-anchored result is already non-future (a
  stale HEAD, such as a `reopened` trigger with no new commit), the
  window anchors on the current time instead. This opens three
  distinct routes. (1) A maintainer can post a per-pull-request
  `idd-external-check-waiver:` marker directly once past that
  `PT9H` deadline. (2) Once this pull request's own
  terminal-unavailable state independently holds (Copilot's
  recovery cycle exhausted and `advisoryWait.terminalWindow`
  elapsed with no current-HEAD review — see
  [`idd-advisory-wait.instructions.md`](../.github/instructions/idd-advisory-wait.instructions.md#terminal-copilot-stall-recovery-contract-state-policy-markers-clock)),
  an active `providerOutage` declaration (target: #158) substitutes
  for posting that per-PR marker. Passing that `PT9H` deadline
  alone does **not** by itself satisfy route (2) — declaring an
  outage without the PR's own terminal state also holding leaves
  the check red. (3) A same-repository pull request whose diff
  touches the committed trigger-file allowlist can get a
  `self-referential-bootstrap-auto` waiver from the gate
  workflow's own job, with no manual waiver and no rerun, under
  the same `idd-claimed` eligibility as the hosted-workflows
  bullet above. The
  allowlist is `.github/idd/config.json`,
  `.github/workflows/idd-advisory-convergence.yml`, and
  `.github/workflows/idd-advisory-convergence-comment.yml`. That
  job runs only on `pull_request_target` and skips a fork. A valid
  marker of this reason is evaluated unconditionally, independent
  of the `PT9H` deadline and of terminal-unavailable state. It
  does not replace routes (1) or (2) for any other reason, actor,
  or check. A manually posted waiver comment does not by itself
  re-run the check — a fresh trigger still has to fire.
  `workflow_dispatch` does **not** reliably refresh the
  current-HEAD required-check rollup (a dispatched run has no
  `pull_request` context to associate with the PR's HEAD SHA) and
  must not be used for that refresh. When a helper runtime is
  available, rerun with `idd-rerun-advisory-convergence --pr <n>
  --apply`: it reruns every rerun-eligible same-named instance in
  order, waits for each to reach a terminal state before the next,
  stops once the rollup resolves, and does not rerun a
  `bot-gated-skip` instance. It reruns a `rerun-budget-held`
  instance only through the helper's `liveCoverageRecoveryPlan`
  and `passedSiblingRecoveryPlan` exceptions. On
  `instructions-only` (no helper runtime), run `gh run rerun
  <run-id>` for each plan entry, waiting for each to finish before
  the next. Before each `gh run rerun`, follow the
  [claim revalidation gate](../.github/instructions/idd-overview-core.instructions.md#claim-revalidation-gate).
  See
  [rerun mechanics](../.github/instructions/idd-ci.instructions.md#rerun-mechanics).
  The comment companion
  `idd-advisory-convergence-comment.yml` reruns that gate for a
  submitted `pull_request_review` from a non-bot actor regardless
  of comment classification. That path skips debounce and passes
  `--refresh-latest --apply`. A primary-bot submission is gated
  to `action_required` and does not reach the step, and a fork
  pull request's review token cannot perform the rerun. A
  `pull_request_review_comment` or
  `issue_comment` reruns only when the comment is IDD-originated
  and debounce does not skip, using plain `--apply`. Arbitrary
  review-comment activity alone is not enough. The gate's own
  triggers are `pull_request` and `pull_request_target` (`opened`,
  `reopened`, `synchronize`), plus `workflow_dispatch` and
  `workflow_call`. It does not trigger on review or review-comment
  events, and it has no `push` trigger. The companion does:
  `pull_request_review` (`submitted`),
  `pull_request_review_comment` (`created`, `edited`, `deleted`),
  and `issue_comment` (`created`). Action pins, runners, and
  permission blocks for these workflows are in
  [Policy decisions](#policy-decisions).
