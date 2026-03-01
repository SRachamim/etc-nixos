---
name: continuous-improvement
description: Suggest and apply improvements to Cursor commands, skills, rules, and subagent prompts after execution. Use proactively after running any command, skill, or subagent — especially when the execution required workarounds, discovered new information, or hit outdated instructions.
---

# Continuous Improvement

After executing a command, skill, rule, or subagent prompt, reflect on the execution and propose improvements to the source artifact so future runs are better.

## When to trigger

Run this analysis whenever you finish executing (or observe the execution of) a Cursor command, skill, rule, or subagent. Look for any of these signals:

- **Discovery**: you had to figure something out at runtime that could have been encoded ahead of time (e.g. an MCP field name, a required parameter, a default value).
- **Workaround**: you deviated from the instructions because they were wrong, incomplete, or outdated.
- **Deprecation**: an API, field, or tool referenced by the artifact no longer exists or behaves differently.
- **Redundancy**: a step is unnecessary or could be collapsed.
- **Missing error handling**: a failure case occurred that the artifact doesn't address.
- **Performance**: a faster or cheaper approach was found (fewer API calls, better defaults, smarter ordering).
- **Accuracy**: the output quality could improve with better prompts, examples, or constraints.

If the execution went smoothly and matched the instructions perfectly, say nothing — don't suggest improvements for their own sake.

## How to propose an improvement

### 1. State what happened

One sentence describing the discrepancy or discovery during execution.

> Example: "`wit_create_work_item` now requires `System.AreaPath` — I had to look it up via `wit_get_work_item` on an existing item before I could create the task."

### 2. Categorize

Label the improvement as one of:

| Category | Meaning |
|----------|---------|
| **new-field** | A field, parameter, or input the artifact doesn't mention |
| **deprecated** | Something the artifact references that no longer works |
| **better-default** | A hardcoded or inferred value that should be pre-set |
| **missing-step** | A step that was needed but not documented |
| **dead-step** | A step that is no longer necessary |
| **error-handling** | A failure mode that should be anticipated |
| **accuracy** | A prompt or instruction that produced suboptimal output |
| **performance** | A way to reduce latency, token cost, or API calls |

### 3. Show the proposed change

Present the specific edit as a before/after diff against the source file.

### 4. Apply or present

Locate the **source file** for the artifact. It may live in the current workspace even if it's deployed elsewhere at runtime (e.g. global skills managed from a dotfiles repo).

- **Source is in the current workspace**: apply the edit directly and ask the user before committing. Follow whichever commit conventions the project uses.
- **Source is truly external** (not managed from this workspace): format the entire proposal as a ready-to-paste agent instruction inside a fenced code block (so the IDE renders a copy button). The block must be self-contained — everything another agent needs to apply the change without extra context:

    ~~~text
    The <command/skill/rule> at <runtime-path> needs an update.

    What happened: <one sentence>
    Category: <category>

    Proposed change to <filename> — <brief scope>:

    <unified diff or before/after snippet>

    This file lives at <path-hint> — apply the diff there.
    ~~~

## Constraints

- **Evidence-based only** — every suggestion must trace back to something that actually happened during execution. Never speculate.
- **Don't break existing behavior** — improvements must be backward-compatible. If unsure, present the change and ask.
- **Minimal diff** — change only what is needed. Don't reformat or restructure surrounding content.
