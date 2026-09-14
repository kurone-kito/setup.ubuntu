# Gemini agent guidelines

For general contribution conventions (language, project scope, commit
rules), follow
[.github/copilot-instructions.md](.github/copilot-instructions.md).

## IDD Workflow

This project uses Issue-Driven Development (IDD) with parallel AI agents.
Start with [docs/idd-workflow.md](docs/idd-workflow.md) for the
cross-agent entry path and phase routing.

Before starting IDD work, open
`.github/instructions/idd-overview-core.instructions.md`. Open the routed
phase file manually when the current step changes.

Recorded policy decisions live in [docs/idd-policy.md](docs/idd-policy.md).

Before every `wt switch --create -b main <new-branch>` (B1 worktree
creation), fast-forward the primary worktree's local `main` first: run
`git pull --ff-only` (or `git fetch origin main` then
`git merge --ff-only origin/main`) from the primary worktree while
`HEAD` is on `main`. `git fetch origin main` alone only updates the
remote-tracking ref `origin/main` — it does **not** move the local
`main` branch, so a stale local `main` silently cuts the new branch
off from work that already merged. See
[B1 — Create worktree (with branch)](.github/instructions/idd-work.instructions.md#b1--create-worktree-with-branch).
