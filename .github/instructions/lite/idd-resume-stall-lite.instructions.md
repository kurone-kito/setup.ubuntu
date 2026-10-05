# IDD — Resume Stalled-Session Recovery (Lite)

Lite profile for weak / local models. Same semantics as
`idd-resume-stall.instructions.md`. Use only for a **non-owned** active
claim with **no** valid human-gated forced-handoff.

Enter from `idd-resume-lite.instructions.md` Step 0. After a successful
takeover, return to resume lite Step 1.

Choose exactly one command form for the configured helper runtime. The
`node scripts/...` form is for a source checkout or `vendored-node`;
`package-manager` uses the named command from
`docs/idd-helper-scripts.md`; this repository's `ephemeral-npx` form is
shown literally below to match `.claude/settings.json`'s Bash allowlist.

## Helper runtime contract

- **Helper-enabled profiles** (`package-manager`/`ephemeral-npx`/
  vendored-node: see `docs/idd-helper-scripts.md`): run the commands
  below. If a required helper is missing, fails, returns invalid JSON,
  or disagrees with live state → **hold and stop** (do not claim). Do
  not invent a silent prose takeover path.
- **`instructions-only`**: use the written S1–S5 steps without helpers,
  including the manual claim-state and fail-closed porcelain worktree
  checks below, still with a server-anchored `now` for the quiet window.

## Helper-first commands (helper-enabled profiles)

Choose only the command under the configured profile.

**Source checkout / vendored-node:**

```sh
node scripts/resume-claim-routing.mjs --issue <N>
```

**Package-manager:** use the named command from
`docs/idd-helper-scripts.md`:

```sh
<profile-selected-resume-claim-routing-command> --issue <N>
```

**This repository's ephemeral-npx profile:** carry
`IDD_HELPER_PACKAGE_SPEC` from B1's trusted common-base resolution. If
this procedure is entered directly or resumed without that value,
resolve it from the trusted primary worktree or trusted default branch
as described in the [helper documentation](../../../docs/idd-helper-scripts.md#trusted-common-base-for-ephemeral-npx);
never read it from this issue/PR checkout. Require it to equal this
immutable pin before invoking (the literal spelling matches
`.claude/settings.json`); if the trusted value cannot be established or
differs, stop. Run this pin comparison separately from each helper
invocation; run each npx command as its own top-level Bash command so
`.claude/settings.json`'s literal-prefix allow rule matches:

```sh
npx --yes --package https://codeload.github.com/kurone-kito/idd-skill/tar.gz/ae16f497434a5023dfaa28f965fc2af92ebf055d idd-resume-claim-routing --issue <N>
```

Derive server-anchored `now` for the quiet window (only if permission
permits):

```sh
set -o pipefail
SERVER_NOW=$(gh api repos/<owner>/<repo>/issues/<N> --include \
  | grep -i '^date:' | tail -1 | sed 's/^[Dd]ate: *//' | tr -d '\r') || exit 1
[ -n "$SERVER_NOW" ] || exit 1
NOW=$(node -e "console.log(new Date(process.argv[1]).toISOString().replace(/\.\d{3}Z$/, 'Z'))" "$SERVER_NOW") || exit 1
```

When a PR exists, run exactly one quiet-window command for that profile.
Without a PR, do not invent `--pr`; use the written S2 procedure below.

**Source checkout / vendored-node:**

```sh
node scripts/stalled-session-quiet-check.mjs \
  --pr <pr-number> \
  --now "$NOW" \
  --claim-created-at <latest-valid-claimed-by-created_at>
```

**Package-manager:**

```sh
<profile-selected-stalled-session-quiet-check-command> \
  --pr <pr-number> --now "$NOW" \
  --claim-created-at <latest-valid-claimed-by-created_at>
```

**This repository's ephemeral-npx profile:** confirm the literal pin
against the trusted common base in a separate step. Run the helper below
as its own top-level Bash command so the literal-prefix allow rule
matches, inserting the captured server timestamp as a literal value.

```sh
npx --yes --package https://codeload.github.com/kurone-kito/idd-skill/tar.gz/ae16f497434a5023dfaa28f965fc2af92ebf055d idd-stalled-session-quiet-check \
  --pr <pr-number> --now {server-now} \
  --claim-created-at <latest-valid-claimed-by-created_at>
```

If direct API reads are blocked by the active permission policy, follow
the approved operator-evidence path in `docs/idd-helper-scripts.md`;
if that evidence is unavailable, hold and stop. Do not widen permissions,
route the request through a wrapper, or use the local clock.

No PR: do not invent `--pr`. Skip the helper (not a helper
failure). Decide S2 from the written bullets using the claim
`branch:` remote tip SHA and update time (no remote branch: treat
absence as no movement only if also absent at S2); S4 step 5 re-reads that tip
and repeats the written S2 checks against a fresh `NOW`; hold
on movement or incomplete evidence.

Never use the local wall clock as `now`. Re-derive a **fresh** `NOW`
before S4; do not reuse the S2 value.

## S1 — Is this a stall case?

| Condition                                                                                  | Action                                    |
| ------------------------------------------------------------------------------------------ | ----------------------------------------- |
| No active claim, or active claim is this session's `{claim-id}`                            | Return to resume lite                     |
| Valid forced-handoff matches the active claim or an inheritable released branch / PR state | Return to resume lite forced-handoff path |
| Active claim is another `{claim-id}`                                                       | Continue to S2                            |

## S2 — Quiet window (30 min, evidence only)

Require **no** external progress in the last 30 minutes:

- no trusted heartbeat on the active claim;
- no PR head or remote branch tip movement;
- no CI `queued` / `in_progress`;
- no new review/comment/CI completion activity.

Helper fields: `quiet_window_met`, `reason`, `latest_activity`.

| Result                                                         | Action                                                 |
| -------------------------------------------------------------- | ------------------------------------------------------ |
| `quiet_window_met` false, or incomplete/contradictory evidence | **Hold and stop** — no claim, push, or review mutation |
| `quiet_window_met` true                                        | Continue to S3                                         |

Quiet window alone never authorizes takeover.

## S3 — Stale threshold (ownership gate)

Takeover only if latest valid trusted `claimed-by` `created_at` is
**≥ 24 h** ago (`claim-stale-age`).

| Claim age | Action            |
| --------- | ----------------- |
| < 24 h    | **Hold and stop** |
| ≥ 24 h    | Continue to S4    |

`heartbeatOverdue` is **diagnostic only**. It does not shorten the 24 h
gate.

For helper-enabled profiles, before S4/posting, rerun the
profile-selected helper; require `stale`/`takeover`,
`evidence.local_worktree.status: absent`; fail → **STOP** (#3141).

For `instructions-only`, re-read the issue and validate the latest
trusted claim markers using the written A5 rules in
`idd-claim-lite.instructions.md` (including explicit-null
`IssueComment.lastEditedAt`). Then run
`git worktree list --porcelain -z` and parse the complete NUL-delimited
records. Match both the expected sibling path for the claimed branch and
any `branch refs/heads/<claimed-branch>` record. Command failure,
malformed/incomplete output, an unreadable matching worktree, or a
matching detached worktree whose canonical root cannot be verified is
occupied/unknown and must stop the route. Only a successful complete
scan with no matching path or branch proves the worktree absent. See
`idd-claim-lite.instructions.md` A5(e) for the full branch-collision
fallback.

## S4 — Race-safe recheck (immediately before write)

1. Run `idd-claim-lite.instructions.md` pre-checks (d)/(e); either
   failing → STOP.
2. Helper-enabled profiles: re-run the profile-selected
   `resume-claim-routing` command from the variants above. For
   `instructions-only`, re-read the issue and repeat S3's written
   claim/edit-state and porcelain worktree checks.
3. Active claim still the same non-owned `{claim-id}`.
4. Still stale (≥ 24 h) now.
5. Fresh server `NOW` + re-run quiet-check (no PR: written S2, not
   helper); if new activity, STOP and restart from resume discovery.
6. Issue still open; PR not merged.
7. Plan A5 takeover with settle delay (`claim.verifySettleDelay`, default
   `PT5S`) and same-second claim-id tie-break.

Any failure → STOP and restart. Do not post takeover on stale evidence.

## S5 — Takeover

Route through `idd-claim-lite.instructions.md`: pre-checks (a)-(e) in
full, then Claim execution with `supersedes: <prior-claim-id>`
(`--record-tokens` before the post and the activation-nonce), then
Claim verification.

Lost → STOP. Verified → return to `idd-resume-lite.instructions.md`
Step 1 with `--claim-id`/`--nonce`.

## Hold behavior

On S2/S3 hold, missing helper, unanchored timestamps, or ambiguous
claim/forced-handoff: session log only (no issue/PR comment); on
`local_worktree_occupied` (S3/S4), include §LWR fields
(`docs/idd-resume-detail.md`). Never invent forced-handoff consent.
