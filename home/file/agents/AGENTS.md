# Agent Instructions

Personal skills and conventions that apply across all projects and all agents.

## Skills

Personal skills are installed globally. Use `/skill-name` to invoke workflow skills.
Knowledge skills load automatically when the agent detects relevant context.

Skill categories:
- **workflows/** -- user-invoked procedures (e.g. `/plan`, `/create-task`, `/review-pr`)
- **knowledge/** -- standards and reference material loaded by context
- **shared/** -- helper sub-workflows called by other skills, not invoked directly

## Conventions

- Follow the **commit-conventions** skill for all git commits.
- Follow the **writing-style** skill for external communications (PR descriptions, work item comments, Slack messages).
- Follow the **gitflow-branching** skill for branch operations, yielding to repository-specific guidelines.
- Follow the **external-communications** skill before posting to any external platform.
- Follow the **decision-priorities** skill when choosing between alternative approaches (simplicity > correctness > changeability > DX).

## Preferences

- Commit messages: imperative mood, conventional commits format, body explains why not what.
- Branch naming: `feature/<name>`, `hotfix/<name>`, `release/<version>` per Gitflow.
- Code style: pure functional TypeScript with fp-ts when working in TypeScript repositories.
- Output style: concise, no filler, evidence-based.
