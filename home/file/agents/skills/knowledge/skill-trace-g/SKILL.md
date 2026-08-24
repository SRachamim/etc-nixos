---
name: skill-trace-g
description: "Lightweight transparency protocol for agent-to-user chat. After tasks where skills or rules shaped the output, appends a trace block listing which artifacts were applied. Mandatory for delivered text (via **delivered-text-g**), recommended for all workflow skill completions. The trace appears only in chat -- never in delivered text."
---

# Skill Trace

Make skill and rule application visible to the user. A skill that was loaded but ignored looks identical to one that was faithfully followed -- this skill closes that gap by requiring a trace block in agent-to-user chat.

## Scope

The trace block appears **only** in agent-to-user chat (IDE conversation). It is never included in delivered text (commits, PRs, Slack messages, work items, code comments, documentation). This preserves operational concealment per **writing-style-g**.

## When to produce a trace

| Level | Condition | Trace required? |
|-------|-----------|-----------------|
| **Mandatory** | Presenting drafted delivered text (via **delivered-text-g**) | Always |
| **Recommended** | Completing a workflow skill or applying knowledge skills to a substantive task | Yes, unless the output is trivial (e.g. "Done.", a one-line confirmation) |
| **Skip** | Pure agent-to-user conversation with no skill involvement | No trace needed |

## What to report

For each skill or rule that participated in the task:

- **Applied** -- the skill's instructions actively shaped the output. List these.
- **Loaded** -- the agent read the SKILL.md but the instructions didn't materially affect the output (e.g. the skill covers a case that didn't arise). Mention only if it helps the user understand what was considered.
- **Skipped** -- a skill was a candidate but deliberately not loaded. Mention with a brief reason only when the omission might surprise the user.

For delivered text, list which layers from the **delivered-text-g** routing table were active (e.g. layers 1--2 for always-on skills, plus any conditional skills by name).

## Format

Append a single line after the task output, separated by a horizontal rule:

```
---
Skills applied: **skill-a-g**, **skill-b-g**, **skill-c-g**
```

When delivered-text-g layers are relevant, include the layer numbers:

```
---
Skills applied: **objective-communication-g** (layer 1), **writing-style-g** (layer 2), **communication-templates-g** (layer 3), **commit-conventions-g** (layer 5)
```

### Format rules

- Use the `**bold-name**` citation convention standard across the skill ecosystem.
- Keep it to one line when possible. Wrap to a second line only if many skills were applied.
- Do not editorialize or explain what each skill did -- the skill name is enough. The user can read the skill if they want details.
- Do not include **skill-trace-g** itself in the trace list.

## Constraints

- **Chat only** -- never embed the trace block in delivered text. The trace is metadata for the user, not content for the audience.
- **Non-blocking** -- if you genuinely cannot determine which skills were applied (e.g. instructions from multiple skills overlap and you can't distinguish), list what you loaded. An imprecise trace is better than no trace.
- **No inflation** -- list only skills that were actually loaded or applied. Do not pad the list with skills that the task could theoretically have used.
