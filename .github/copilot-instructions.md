# Guidelines for AI Agents

This project is a setup the dev environment for Ubuntu.

When contributing to this repository using AI agents, adhere to the
following guidelines to ensure high-quality contributions that align with
the project's standards and practices:

## Conversation

- The conversational language should match the user's language.
  For example, if the user speaks in Japanese, respond in Japanese.
- However, comments and documentation should be written in English unless
  there is a clear context otherwise.
- If uncertainties, concerns, or other implementation issues arise while
  running in Agent mode, promptly switch to Plan mode and ask the user
  questions. In such cases, provide one or more recommended response
  options.

## Project scope

The scope of this project is to install software on Ubuntu and perform the
minimum necessary configuration required. Configuration matters are the
responsibility of the [dotfiles](https://github.com/kurone-kito/dotfiles)
repository. Some CLI installs are also owned by dotfiles, via its shared
mise config — see [docs/dotfiles-boundary.md](../docs/dotfiles-boundary.md)
for the layer boundary.

## Homebrew

This repository's Homebrew path is **formulae-only**: `lib/Brewfile`
may use `brew 'name'`, never `cask 'name'`. A token is a `(B)` marker
candidate (the marker used in `README.md`/`README.ja.md`'s app tables)
only after `brew info --formula NAME` succeeds on Linux — `brew info`,
`brew search`, and `brew install --dry-run` can resolve a **cask** on
this Ubuntu Linuxbrew and must not be treated as formula evidence.
Classic `app`/`pkg` casks remain macOS-only, but since Homebrew 4.5.0
some casks ship Linux `binary` artifacts and are no longer universally
macOS-only; neither fact makes a cask in-scope here.

## Documentation

`README.md` and `README.ja.md` document the same tool inventory in
different languages. Any change to the tool inventory in `README.md`
(adding, removing, or re-describing an installed tool) must update
`README.ja.md` in the same change, so the two files never drift apart.

## IDD Workflow

This project uses Issue-Driven Development (IDD) with parallel AI agents.
Start with [docs/idd-workflow.md](../docs/idd-workflow.md) for the
cross-agent entry path and phase routing.

Before starting IDD work, open
`.github/instructions/idd-overview-core.instructions.md`. Open the routed
phase file manually when the current step changes.

Recorded policy decisions live in
[docs/idd-policy.md](../docs/idd-policy.md).

Before every `wt switch --create -b main <new-branch>` (B1 worktree
creation), fast-forward the primary worktree's local `main` first: run
`git pull --ff-only` (or `git fetch origin main` then
`git merge --ff-only origin/main`) from the primary worktree while
`HEAD` is on `main`. `git fetch origin main` alone only updates the
remote-tracking ref `origin/main` — it does **not** move the local
`main` branch, so a stale local `main` silently cuts the new branch
off from work that already merged. See
[B1 — Create worktree (with branch)](instructions/idd-work.instructions.md#b1--create-worktree-with-branch).

## Commit rules

This project follows
[Conventional Commits](https://www.conventionalcommits.org/).
A `.gitmessage` template is available at the repository root for
guidance when writing commit messages. Git does not use it
automatically, so contributors who want the template prefilled in
their editor should opt in once per clone:

```sh
git config commit.template .gitmessage
```

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

- Optional, in parentheses: `feat(ci):`, `fix(lint):`, `docs(readme):`
- Keep scopes **lowercase**, short, and consistent
- Use the directory or component name that best describes the area

### Body (line 3+)

The body should address three aspects:

- **Why** — the purpose or motivation behind the change
- **Context** — what was needed, the situation or constraint
- **What changed** — the concrete action taken

Prefer the **why → context → change** order when practical.
Write these as **natural prose** — weave the aspects into coherent
sentences rather than using labeled sections. Labeled sections
(`Why:` / `Context:` / `Change:`) are acceptable only when explicit
paragraph separation improves clarity.

Omit any aspect whose information **cannot be reliably inferred**.
If the subject line is self-explanatory, the body may be omitted
entirely. **Breaking changes must always include a body.**

Wrap body lines at **72 characters**.

### Breaking changes

- Append `!` after the type/scope: `feat!: remove deprecated endpoint`
- Add a `BREAKING CHANGE:` trailer in the footer with a detailed
  explanation of what breaks and migration steps

### Footers / trailers

- `Closes #<issue>` / `Refs #<issue>` — link to issues
- `Co-authored-by: Name <email>` — credit co-authors
- `BREAKING CHANGE: <description>` — detail the breaking change

### Atomic commits

Keep each commit as **small and focused** as possible:

- **One logical change per commit** — if the subject line needs
  "and", consider splitting
- **Separate refactoring** from behavior changes
- **Separate formatting/style** changes from logic changes
- **Separate dependency updates** from code changes
- When in doubt, prefer smaller commits that are easy to review,
  revert, and bisect

### Examples

#### Good — single-line (trivial change)

```txt
fix: correct typo in feature request template
```

#### Good — prose body

```txt
feat(ci): add concurrency settings to lint workflow

Parallel lint runs on the same branch waste resources and
cause race conditions in status checks. GitHub Actions
supports concurrency groups that automatically cancel
redundant runs, so add a concurrency group keyed on branch
name with cancel-in-progress enabled.

Refs #42
```

#### Good — breaking change

```txt
feat!: require node 20 as minimum version

Node 18 reached end-of-life in April 2025 and no longer
receives security updates, while the project now standardizes
on the active Node 20 LTS baseline. All production
environments have already been upgraded to node 20+, so
update the engines field and CI matrix to require node >= 20.

BREAKING CHANGE: drop support for node 16 and 18. Users
must upgrade to node 20 or later.
Closes #108
```

#### Bad — vague, developer-centric

```txt
fix: update code
```

#### Bad — too large / non-atomic

```txt
feat: add auth system and refactor database layer and update docs
```

## Coding standards

- **Indentation**: 2 spaces (enforced by `.editorconfig`)
- **Line endings**: LF only (enforced by `.editorconfig` and
  `.gitattributes`)
- **Trailing whitespace**: trimmed (except in Markdown)
- **Final newline**: always present
- **File naming**: lowercase with hyphens (e.g.,
  `feature-request.yml`) unless constrained by a platform convention
  (e.g., `CONTRIBUTING.md`)

## Guardrails

- **Do not** modify community documents (CODE_OF_CONDUCT, CONTRIBUTING)
  without explicit approval
