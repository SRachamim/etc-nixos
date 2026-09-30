# Agent Instructions

Personal skills and conventions that apply across all projects and all agents.

## Skills

Personal skills are installed globally and end with `-g` to distinguish them from repo-level skills. Use `/skill-name-g` to invoke workflow skills.
Knowledge skills load automatically when the agent detects relevant context.

Skill categories:
- **workflows/** -- user-invoked procedures (e.g. `/plan-g`, `/create-task-g`, `/review-pr-g`)
- **knowledge/** -- standards and reference material loaded by context
- **shared/** -- helper sub-workflows called by other skills, not invoked directly

## Conventions

- Follow the **commit-conventions-g** skill for all git commits.
- Follow the **delivered-text-g** skill for all delivered text (committed, posted, published). It defines scope, priority ladder, and routes to the right sub-skills (**objective-communication-g**, **writing-style-g**, **communication-templates-g**, **external-communications-g**) by text type.
- Follow the **gitflow-branching-g** skill for branch operations, yielding to repository-specific guidelines.
- Follow the **decision-priorities-g** skill when choosing between alternative approaches (simplicity > correctness > changeability > DX).
- Follow the **artifact-layering-g** skill when encountering repo-level skills that overlap with user-level (`-g`) skills.
- Follow the **skill-trace-g** skill to report which skills and rules shaped the output in agent-to-user chat.

## Nix shell environments

In a project with a Nix dev shell (an `.envrc` with `use flake`/`use nix`, a `shell.nix`, or a `flake.nix` with `devShells`), run toolchain commands through `direnv exec . <cmd>`, falling back to `nix develop -c <cmd>` or `nix-shell --run "<cmd>"`. Skip the prefix for read-only git metadata (`git status`, `git log`, `git diff`) and plain file commands (`ls`, `cp`), but keep it for git commands that run hooks (`git commit`, `git merge`, `git rebase`, `git push`). Don't install tools globally; the shell provides them.

## Preferences

- Code style: pure functional TypeScript with fp-ts when working in TypeScript repositories.
- Output style: concise, no filler, evidence-based.
- MCP server selection: when a native server and a proxy both offer an operation, follow the **mcp-namespace-priority-g** skill (native first; the FundGuard proxy only for Datadog, Currents, Sunday, DevTools and DevOps Tools).

## Model Routing

Match the model tier (Volume, Standard, Frontier) to the task's cognitive demand; the **context-engineering-g** skill has the tier table. Default subagents to **Volume** unless the task reasons across files or domains. When a result is poor, escalate one tier and don't retry at the same tier twice.
