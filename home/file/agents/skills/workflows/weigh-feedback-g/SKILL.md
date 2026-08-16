---
name: weigh-feedback-g
description: >-
  Evaluates received PR feedback against governing standards and produces a
  structured reaction plan with per-comment verdicts. Use when processing PR
  review comments as the PR author.
disable-model-invocation: true
---

# Weigh Feedback

Evaluate received PR feedback and act on it. Loads the **feedback-evaluation-g** framework for independent evaluation of each comment, then executes approved actions.

## Steps

### 0. Mode gate

Require **Plan** mode following the **mode-gate-g** skill. Steps 1--3 are read-only deliberation: no code changes, PR replies, or Slack messages until the reaction plan is approved. Switch to **Agent** mode for execution (step 4).

### 1. Gather context

Identify the PR from explicit input, the current branch, or conversation context. List all active, unresolved comment threads.

### 2. Evaluate

Apply the **feedback-evaluation-g** skill to evaluate each comment thread independently. For each comment, produce a verdict using the evaluation protocol and decision categories defined in that skill.

### 3. Present reaction plan

After evaluating all comments, produce a structured reaction plan:

| Comment | Verdict | Governing standard | Proposed action |
|---------|---------|-------------------|-----------------|
| File path + line, first sentence (truncated) | One of the five verdicts | Skill/rule name + relevant section (or "general principles") | Code change summary, full draft reply text (composed per **delivered-text-g** stack, in a fenced code block), or question to ask |

Present the full reaction plan to the user. The user may:

- Approve all
- Approve selectively
- Override specific verdicts
- Request re-evaluation of specific comments

Do not proceed to execution until the user approves.

### 4. Execute

After approval, switch to **Agent** mode and execute:

**PR thread replies**: for each approved comment, post a reply. Apply the **external-communications-g** skill and the **objective-communication-g** skill for tone and formatting. Structure by verdict:

- **Agree-fix / Partial** -- acknowledge the concern, reference the fix or alternative approach.
- **Disagree** -- state the governing standard, explain the reasoning concisely, propose keeping the current approach.
- **Need-context** -- ask the targeted question.
- **Agree-defer** -- acknowledge validity, explain why it's deferred, and what the user will decide.

**Code changes**: for "Agree-fix" and "Partial" verdicts, make the changes. Follow **commit-conventions-g** for commit structure.

**Slack thread reply**: post a summary in the relevant Slack thread. Identify the thread from conversation context or a preceding `/submit-feature-g` or `/review-pr-g` invocation. If no thread is identifiable, skip and note this to the user.

### 5. Evolve

Follow the **continuous-improvement-g** skill.
