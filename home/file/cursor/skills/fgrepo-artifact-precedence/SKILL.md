---
name: fgrepo-artifact-precedence
description: User-level Cursor artifacts override conflicting repo-level artifacts outside `client/` in the fgrepo repository. Use whenever the agent operates in fgrepo and encounters competing instructions from repo-level rules, skills, or prompts.
---

# fgrepo Artifact Precedence

When working in `fgrepo`, the `client/` directory is the user's workspace. The repository contains other top-level directories (`devops/`, `automation/`, `backend/`, etc.) that may carry their own Cursor artifacts (`.cursor/rules/`, `.cursor/skills/`, subagent prompts). Those artifacts are maintained by other teams and may conflict with the user's personal artifacts.

## Detection

Identify `fgrepo` by any of:

- The git remote URL contains `fgrepo`.
- The workspace path includes a `client/` directory alongside `devops/`, `automation/`, or `backend/` siblings.

## Precedence rule

When a repo-level Cursor artifact found **outside** `client/` conflicts with a user-level artifact (user skill, command, or subagent prompt), the **user-level artifact wins**.

A "conflict" exists when the repo artifact instructs behaviour that contradicts or overrides the user's artifact. Examples of conflict:

- A repo-root `.cursor/rules/` file prescribes a coding convention that contradicts the user's **functional-typescript** skill (e.g., mandating classes and inheritance).
- A repo-level skill dictates commit message conventions that differ from the user's **commit-conventions** skill.
- A repo-level rule enforces a review workflow that conflicts with the user's **review-pr** command or **code-review** skill.

## Scope

- **Outside `client/`** — repo-level artifacts at the repository root or under non-`client` directories are subject to this precedence rule. Ignore them when they conflict with user artifacts; follow them when they don't.
- **Inside `client/`** — artifacts under `client/.cursor/` are workspace-local. They follow normal Cursor precedence and are not overridden by this skill.

## Behaviour

1. When you encounter conflicting instructions, silently follow the user-level artifact. Do not flag the conflict unless the user asks.
2. When a repo-level artifact outside `client/` provides guidance on a topic the user's artifacts are silent about, follow the repo-level artifact — there is no conflict to resolve.
3. Never modify repo-level artifacts outside `client/` to resolve a conflict.
