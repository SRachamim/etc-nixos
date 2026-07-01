---
name: retrospective
description: Reviews recent agent transcripts for recurring friction, workarounds, and failures, then proposes batch improvements to skills, rules, and subagent prompts. Use on-demand or as a scheduled weekly automation to keep the skill ecosystem evolving from evidence.
disable-model-invocation: true
---

# Retrospective

Review recent agent transcripts to identify recurring patterns of friction, then propose batch improvements to the skill ecosystem. This is the **proactive** complement to **continuous-improvement** (which is reactive and per-execution).

## Input

- **Default**: review transcripts from the current workspace's `agent-transcripts/` directory -- last 7 days or last 20 sessions, whichever is smaller.
- **Explicit scope**: user specifies a time range, session count, or specific transcript IDs.
- **Cross-workspace**: user provides a path to another workspace's transcript directory.

## Steps

### 0. Enter Plan mode

Require **Plan** mode following the **mode-gate** skill. The entire analysis (steps 1--6) is read-only.

### 1. Gather transcripts

List available transcripts in scope. For each, read only the first and last few lines to extract metadata (timestamps, session topic). Do NOT load full transcript content into context.

Select the N most recent within scope. If more than 20 are in range, sample: prioritise sessions that are unusually long (many turns) or contain error indicators in their filenames/metadata.

### 2. Scan for signals

For each transcript, search (grep) for signal patterns without reading full content:

| Signal | Search patterns |
|--------|----------------|
| Errors and retries | `exit code: 1`, `commit blocked`, `failed`, `Error:`, `rejected` |
| Workarounds | `let me try`, `different approach`, `instead`, `workaround` |
| Repeated discovery | Same search query appearing multiple times in one session |
| Skill references | `**skill-name**`, `/skill-name`, `Follow the` |
| Context pressure | Sessions with very high line counts relative to task complexity |

Read only small windows (5 lines before/after) around each signal hit. Summarise each transcript's signals in 2-3 bullet points before moving to the next.

### 3. Identify patterns

Cluster findings across transcripts. Look for:

- The same friction appearing in 3+ sessions (recurring).
- A specific skill being consistently problematic (skill-level issue).
- Missing guidance that forced runtime discovery each time (gap).
- Sessions that should have been short but ran long (efficiency).
- Errors that the skill ecosystem should have prevented (missing guardrail).

Discard one-off incidents -- focus only on patterns with evidence from multiple sessions.

### 4. Categorise and propose

For each recurring pattern, produce a proposal using the same categories as **continuous-improvement**:

| Category | Meaning |
|----------|---------|
| **new-field** | A field, parameter, or input the artifact doesn't mention |
| **deprecated** | Something the artifact references that no longer works |
| **better-default** | A value that should be pre-set rather than discovered at runtime |
| **missing-step** | A step that was needed but not documented |
| **dead-step** | A step that is no longer necessary |
| **error-handling** | A failure mode that should be anticipated |
| **accuracy** | A prompt or instruction that produced suboptimal output |
| **performance** | A way to reduce latency, token cost, or API calls |
| **new-artifact** | A pattern recurring often enough to warrant a new skill or rule |

For each proposal, specify:

- **Pattern**: what keeps happening (1 sentence).
- **Evidence**: which sessions showed this (transcript IDs or dates).
- **Affected artifact**: path to the skill, rule, or subagent prompt.
- **Proposed change**: specific edit (before/after) or new artifact description.
- **Confidence**: high (5+ sessions) / medium (3-4 sessions) / low (2 sessions, strong signal).

### 5. Present report

Apply the **objective-communication** skill to all composed text.

Output the retrospective in this format:

```
## Agent Retrospective: <date range>

### Sessions reviewed: N

### Patterns found

| # | Pattern | Frequency | Affected artifact | Category | Confidence |
|---|---------|-----------|-------------------|----------|------------|

### Proposed improvements

#### 1. <title>

**Pattern**: <what keeps happening>
**Evidence**: <session IDs or dates>
**Affected artifact**: <path>
**Proposal**: <specific change or new artifact>

...

### No-action items

<Patterns observed but not actionable, or improvements already in progress>
```

### 6. Iterate

Wait for the user to approve, modify, or reject each proposal. Approved proposals are applied following **continuous-improvement** mechanics (locate source file, apply edit, commit).

### 7. Evolve

Follow the **continuous-improvement** skill.

## Context engineering

Transcripts can be enormous. This skill must NOT load full transcripts into context:

- Use grep/search to find signal lines, not sequential reading.
- Read only small windows around signals (5 lines context).
- Summarise per-transcript findings into bullets before cross-transcript analysis.
- Target 60-80% context utilisation per the **context-engineering** skill.
- If the signal scan produces too many hits, increase the recurrence threshold (e.g., only patterns in 4+ sessions).

## Scheduling as an automation

Per the **event-driven-automations** skill, this can run as a scheduled automation:

- **Trigger**: Cron (weekly, Monday morning).
- **Instruction**: "Follow the `/retrospective` skill. Review transcripts from the past week. Post the report to Slack."
- **Tier**: Volume (pattern-matching across text, not deep architectural reasoning).

## When NOT to use this skill

- After a single session -- use **continuous-improvement** instead.
- When you already know the specific problem -- just fix the skill directly.
- When transcripts are unavailable or the workspace has fewer than 5 sessions to review.
