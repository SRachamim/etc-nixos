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

## Model Routing

Classify tasks by cognitive demand and select the appropriate model tier. This guidance is portable across all agents and platforms -- it never names specific models or providers.

| Tier | Cognitive demand | Task examples | Model guidance |
|------|-----------------|---------------|----------------|
| **Frontier** | Complex reasoning, long-chain planning, cross-cutting architectural judgement | Architecture decisions, security audits, complex cross-repo debugging, multi-file refactors with subtle dependency chains | Use the most capable model available. ~5-15% of tasks. |
| **Standard** | Multi-step reasoning, moderate context | Standard implementation, code review, test generation, single-file refactoring, PR descriptions | Use the platform's default/recommended model. ~25-35% of tasks. |
| **Volume** | Mechanical, well-scoped, low ambiguity | Boilerplate, documentation, classification, bulk file edits, read-only exploration subagents, commit message drafting | Use the fastest/cheapest model available. ~50-60% of tasks. |

### Routing rules

- When spawning subagents, default to **Volume** tier unless the task requires reasoning across multiple files or domains.
- When the agent can choose its own model, select based on tier.
- When the platform doesn't support model selection, ignore this section -- the guidance is advisory, not blocking.
- Never name specific model slugs in this file. Model names belong in agent-specific configuration.

### Escalation heuristic

If a Volume-tier task fails or produces low-quality output on the first attempt, retry at Standard tier before involving the user. If a Standard-tier task fails, escalate to Frontier. Don't retry at the same tier more than once.
