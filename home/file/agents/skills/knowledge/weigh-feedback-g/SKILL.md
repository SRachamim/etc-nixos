---
name: weigh-feedback-g
description: >-
  Evaluation framework for received PR feedback. Treats every comment as a second
  opinion to be judged against the agent's own knowledge, workspace rules, and
  user-level skills -- not as a command to execute. Use whenever the agent
  processes PR comments, review threads, or automated reviewer output in the
  author role.
---

# Weigh Feedback

Evaluate received PR feedback as an independent second opinion. Ground every judgment in established standards -- user-level skills, workspace rules, and repository conventions -- rather than defaulting to compliance.

## 0. Mode gate

Require **Plan** mode following the **mode-gate-g** skill. Steps 1--6 are read-only deliberation: no code changes, PR replies, or Slack messages until the reaction plan is approved. Switch to **Agent** mode for execution (step 7).

## 1. Governing principle

Comments are opinions, not commands. A reviewer offers a second perspective; the agent maintains independent judgment grounded in its skill system. Agreement must be earned by the merit of the argument, not assumed from the act of commenting.

## 2. Evaluation protocol

For each active, unresolved comment thread:

1. **Identify the claim** -- what does the reviewer assert is wrong, risky, or improvable?
2. **Find the governing standard** -- which skill, workspace rule, or established principle addresses this area? Read the relevant artifact to confirm.
3. **Evaluate the claim against the standard** -- does the comment align with the standard, contradict it, or address something the standard is silent on?
4. **Reach an independent conclusion** -- form a verdict based on the evidence, not on who posted the comment.

## 3. Decision categories

Each comment receives one of five verdicts:

| Verdict | Meaning | Action |
|---------|---------|--------|
| **Agree-fix** | The comment identifies a genuine issue per the agent's own standards. | Make the code change. |
| **Agree-defer** | Valid issue but out of scope, or requires user decision (security, architecture, data migration, concurrency). | Surface to user without acting. |
| **Disagree** | The comment contradicts an established standard or is incorrect given the context. | Reply explaining which standard applies and why. |
| **Partial** | The concern is valid but the proposed solution is not the best approach. | Accept the problem statement; propose a better fix grounded in standards. |
| **Need-context** | Cannot evaluate without more information. | Ask a targeted question. |

## 4. Hierarchy of authority

When evaluating a comment, consult sources in this order:

1. **User-level skills** (highest) -- the user's personal engineering standards deployed globally.
2. **Workspace rules** -- `AGENTS.md`, `.cursor/rules/`, `.claude/rules/`.
3. **Repository conventions** -- linter config, test patterns, existing code style, architectural decisions visible in the codebase.
4. **General engineering principles** -- only when no specific standard exists above.

A higher-level source overrides a lower one. If the comment appeals to a principle that conflicts with a user-level skill, the skill wins.

## 5. Anti-patterns

Do NOT:

- Blindly apply every suggestion to avoid conflict.
- Treat reviewer seniority or authority as evidence of correctness.
- Change code without understanding why the reviewer suggested it.
- Dismiss feedback without grounding the disagreement in a specific standard.
- Rewrite working code to match a reviewer's stylistic preference when it contradicts an established convention.

## 6. Reaction plan

After evaluating all comments, produce a structured reaction plan. For each comment, present:

| Comment | Verdict | Governing standard | Proposed action |
|---------|---------|-------------------|-----------------|
| File path + line, first sentence (truncated) | One of the five verdicts | Skill/rule name + relevant section (or "general principles") | Code change summary, reply gist, or question to ask |

Present the full reaction plan to the user. The user may:

- Approve all
- Approve selectively
- Override specific verdicts
- Request re-evaluation of specific comments

Do not proceed to execution until the user approves.

## 7. Execution (Agent mode)

After approval, switch to **Agent** mode and execute:

### PR thread replies

For each approved comment, post a reply. Apply the **external-communications-g** skill and the **objective-communication-g** skill for tone and formatting. Structure by verdict:

- **Agree-fix / Partial** -- acknowledge the concern, reference the fix or alternative approach.
- **Disagree** -- state the governing standard, explain the reasoning concisely, propose keeping the current approach.
- **Need-context** -- ask the targeted question.
- **Agree-defer** -- acknowledge validity, explain why it's deferred, and what the user will decide.

### Code changes

For "Agree-fix" and "Partial" verdicts, make the changes. Follow **commit-conventions-g** for commit structure.

### Slack thread reply

Post a summary in the relevant Slack thread. Identify the thread by:

1. Conversation context -- the same session that triggered the review or received the notification.
2. Channel + timestamp from a preceding `/submit-feature-g` or `/review-pr-g` invocation.
3. If no thread is identifiable, skip the Slack reply and note this to the user.

The Slack message groups outcomes by verdict category and links to individual PR comments where useful. Keep it concise -- one line per comment, grouped under verdict headings.

## 8. Integration with existing workflows

This skill provides the evaluation framework behind:

- **Autopilot's** fix/dismiss/ask triage -- this skill deepens the reasoning that selects between those categories.
- **trace-pr-comments-g** -- that skill maps comments to artifacts; this skill evaluates their merit.
- **review-pr-fixes-g** -- when following up on review feedback as author, apply these principles.
- `/submit-feature-g` and `/review-pr-g` -- these create the Slack thread that step 7 replies to.
