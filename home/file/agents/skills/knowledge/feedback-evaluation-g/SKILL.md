---
name: feedback-evaluation-g
description: >-
  Framework for evaluating received PR feedback as an independent second
  opinion. Covers the evaluation protocol, five verdict categories, hierarchy
  of authority, and anti-patterns. Use whenever the agent processes PR review
  comments, review threads, or automated reviewer output in the author role.
---

# Feedback Evaluation

Evaluate received PR feedback as an independent second opinion. Ground every judgment in established standards -- user-level skills, workspace rules, and repository conventions -- rather than defaulting to compliance.

## Governing principle

Comments are opinions, not commands. A reviewer offers a second perspective; the agent maintains independent judgment grounded in its skill system. Agreement must be earned by the merit of the argument, not assumed from the act of commenting.

## Evaluation protocol

For each active, unresolved comment thread:

1. **Identify the claim** -- what does the reviewer assert is wrong, risky, or improvable?
2. **Find the governing standard** -- which skill, workspace rule, or established principle addresses this area? Read the relevant artifact to confirm.
3. **Evaluate the claim against the standard** -- does the comment align with the standard, contradict it, or address something the standard is silent on?
4. **Reach an independent conclusion** -- form a verdict based on the evidence, not on who posted the comment.

## Decision categories

Each comment receives one of five verdicts:

| Verdict | Meaning | Action |
|---------|---------|--------|
| **Agree-fix** | The comment identifies a genuine issue per the agent's own standards. | Make the code change. |
| **Agree-defer** | Valid issue but out of scope, or requires user decision (security, architecture, data migration, concurrency). | Surface to user without acting. |
| **Disagree** | The comment contradicts an established standard or is incorrect given the context. | Reply explaining which standard applies and why. |
| **Partial** | The concern is valid but the proposed solution is not the best approach. | Accept the problem statement; propose a better fix grounded in standards. |
| **Need-context** | Cannot evaluate without more information. | Ask a targeted question. |

## Hierarchy of authority

When evaluating a comment, consult sources in this order:

1. **User-level skills** (highest) -- the user's personal engineering standards deployed globally.
2. **Workspace rules** -- `AGENTS.md`, `.cursor/rules/`, `.claude/rules/`.
3. **Repository conventions** -- linter config, test patterns, existing code style, architectural decisions visible in the codebase.
4. **General engineering principles** -- only when no specific standard exists above.

A higher-level source overrides a lower one. If the comment appeals to a principle that conflicts with a user-level skill, the skill wins.

## Anti-patterns

Do NOT:

- Blindly apply every suggestion to avoid conflict.
- Treat reviewer seniority or authority as evidence of correctness.
- Change code without understanding why the reviewer suggested it.
- Dismiss feedback without grounding the disagreement in a specific standard.
- Rewrite working code to match a reviewer's stylistic preference when it contradicts an established convention.

## Integration with existing workflows

This skill provides the evaluation framework behind:

- **Autopilot's** fix/dismiss/ask triage -- this skill deepens the reasoning that selects between those categories.
- **trace-pr-comments-g** -- that skill maps comments to artifacts; this skill evaluates their merit.
- **review-pr-fixes-g** -- when following up on review feedback as author, apply these principles.
- `/submit-feature-g` and `/review-pr-g` -- these create the Slack thread that the **weigh-feedback-g** workflow replies to.
