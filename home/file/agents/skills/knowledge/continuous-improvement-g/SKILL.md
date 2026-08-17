---
name: continuous-improvement-g
description: Methodology for identifying improvements to agent skills, rules, and subagent prompts after execution. Defines signal types, categories, and proposal format. Loaded by capture-improvement-g and review-retrospective-g -- not invoked directly.
---

# Continuous Improvement

Methodology for reflecting on skill execution and proposing improvements to agent artifacts. This knowledge skill defines what to look for and how to structure proposals. The **capture-improvement-g** workflow applies this methodology and acts on the findings.

## Signals

Look for these signals during or after execution:

- **Discovery**: you had to figure something out at runtime that could have been encoded ahead of time (e.g. an MCP field name, a required parameter, a default value).
- **Workaround**: you deviated from the instructions because they were wrong, incomplete, or outdated.
- **Deprecation**: an API, field, or tool referenced by the artifact no longer exists or behaves differently.
- **Redundancy**: a step is unnecessary or could be collapsed.
- **Missing error handling**: a failure case occurred that the artifact doesn't address.
- **Performance**: a faster or cheaper approach was found (fewer API calls, better defaults, smarter ordering).
- **Accuracy**: the output quality could improve with better prompts, examples, or constraints.
- **Recurring friction**: the same painful step appears across multiple executions. "If it hurts, do it more often" -- automate or simplify it rather than working around it each time.
- **Cost of inaction**: the artifact's current state causes repeated delay, confusion, or error. The cost of not improving accumulates -- flag it even if no single execution failed.

If the execution went smoothly and matched the instructions perfectly, there is nothing to propose.

## Categories

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

## Proposal format

Each proposal has three parts:

### 1. State what happened

One sentence describing the discrepancy or discovery during execution.

> Example: "`create_work_item` now requires `System.AreaPath` -- I had to look it up via `get_work_item` on an existing item before I could create the task."

### 2. Categorize

Label the improvement using one of the categories above.

### 3. Show the proposed change

Present the specific edit as a before/after diff against the source file.

## Constraints

- **Evidence-based only** -- every suggestion must trace back to something that actually happened during execution. Never speculate.
- **Don't break existing behavior** -- improvements must be backward-compatible. If unsure, present the change and ask.
- **Minimal diff** -- change only what is needed. Don't reformat or restructure surrounding content.
