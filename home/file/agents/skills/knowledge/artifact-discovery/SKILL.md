---
name: artifact-discovery
description: Analyzes branch or PR code changes to identify opportunities for new or evolved agent artifacts (rules, skills, subagent prompts) in the target repository. Suggestions are grounded in the actual work just completed. Use after significant implementation work -- especially before submitting a feature for review.
---

# Artifact Discovery

After significant implementation work, analyze the code changes on the current branch to identify opportunities for agent artifacts that would help the repository maintain, extend, or govern the patterns just introduced. Every suggestion must be grounded in the actual diff -- never speculative.

## When to apply

- After completing a feature or significant implementation (referenced from **submit-feature**).
- When the agent detects infrastructure, conventions, or workflows were introduced or significantly modified.
- Not useful for trivial changes (typo fixes, dependency bumps, single-line bug fixes).

## How to analyze

### 1. Gather the diff

Run `git diff <default-branch>...HEAD --stat` for an overview, then `git diff <default-branch>...HEAD` for full content. For large diffs, use `--stat` first and selectively read the most significant files.

Also consider thread context -- what was the task about? The work item description, PR title, or conversation history provide intent that the raw diff cannot.

### 2. Categorize changes

Classify what the diff introduced or modified. Not every category will apply -- focus on the ones with the strongest signal.

| Category | Examples |
|----------|----------|
| **Infrastructure / frameworks** | Feature toggles, caching layer, auth middleware, API gateway, message bus |
| **Domain concepts** | New entities, value objects, aggregates, bounded contexts |
| **Conventions** | Naming patterns, folder structure, error handling approach, logging format |
| **Workflows** | Migration scripts, data seeding, release procedures, deployment pipelines |
| **Configuration structures** | Env vars, config schemas, feature flags, secrets management |
| **Integration points** | New APIs, external service connections, MCP servers, webhook handlers |

### 3. Survey existing repo artifacts

List existing rules and skills in the target repository:

- `.cursor/rules/` -- Cursor workflow rules
- `.claude/rules/` -- Claude Code workflow rules
- `AGENTS.md` -- portable workspace-level guidance
- Any skill directories (`.cursor/skills/`, `.claude/skills/`, etc.)

Understand what is already covered so suggestions are non-redundant.

### 4. Identify opportunities

For each significant category from step 2, evaluate whether the pattern would benefit from an agent artifact:

| Question | Artifact type |
|----------|---------------|
| Does this pattern need **enforcement** when related files change? | Workspace rule (glob-triggered) |
| Does this pattern need **automation** to create new instances? | Workflow skill |
| Does this pattern have **co-change requirements** (files that must change together)? | Workspace rule or guard |
| Does this pattern establish **standards** that other work should follow? | Knowledge skill or `AGENTS.md` amendment |
| Would a **guard** prevent common mistakes with this pattern? | Workspace rule with validation steps |

Also consider whether an existing artifact should be **evolved** rather than a new one created. Amending is preferred over proliferating.

### 5. Filter and rank

Apply these filters before presenting:

- **Grounded**: every suggestion must cite a specific file or pattern from the diff. If you cannot point to the code that motivates the suggestion, discard it.
- **Proportionate**: the artifact's complexity matches the pattern's risk and expected frequency of use.
- **Non-redundant**: not already covered by an existing artifact in the repository.
- **Actionable**: the user can create it now with clear scope -- not a vague aspiration.

Rank by expected value: frequency of the pattern multiplied by the cost of getting it wrong without the artifact.

## Suggestion format

Present each suggestion as a structured block:

- **Type**: workspace rule, knowledge skill, workflow skill, or `AGENTS.md` amendment.
- **Action**: create new artifact **or** evolve existing (cite path to existing artifact).
- **Trigger / scope**: when the artifact fires or what it governs.
- **Rationale**: 1-2 sentences linking the suggestion to specific files or patterns from the diff.
- **Example scenario**: one concrete example of when this artifact would activate in future work.

## Constraints

- **Evidence-based only** -- every suggestion traces to the actual diff. Never speculate about what the codebase "might need someday."
- **Repository-scoped** -- suggest artifacts for the target repository, not the global skill ecosystem. Improving global skills is the domain of **continuous-improvement**.
- **Cap at 5** -- do not suggest more than 5 artifacts. Prioritize the highest-value ones.
- **Suggestive, not generative** -- present suggestions to the user; do not create artifacts autonomously. Creation is delegated to `/add-agent-behavior` or manual editing.
- **Skip silently** -- if the diff is trivial (fewer than 20 lines changed, only test files, or only documentation), produce no suggestions.

## Related skills

- **continuous-improvement** -- improves the artifacts that were *used* during execution. Artifact discovery suggests *new* artifacts based on the code that was *written*.
- **retrospective** -- batch-analyzes transcript history for recurring friction. Artifact discovery is per-feature, not per-history.
- **workspace-rules** -- governs how to create workspace rules once the user decides to act on a suggestion.
- **tooling-enforcement** -- if a suggested convention can be enforced by tooling (linter, compiler, CI), note that alongside the artifact suggestion.
