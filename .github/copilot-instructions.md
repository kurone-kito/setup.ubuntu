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
repository.

## IDD Workflow

This project uses Issue-Driven Development (IDD) with parallel AI agents.
Start with [docs/idd-workflow.md](../docs/idd-workflow.md) for the
cross-agent entry path and phase routing.

Before starting IDD work, open
`.github/instructions/idd-overview-core.instructions.md`. Open the routed
phase file manually when the current step changes.

Recorded policy decisions live in
[docs/idd-policy.md](../docs/idd-policy.md).
