---
name: triage-finding-g
description: "Given a single user-authored review note, evaluate it against the agent's raw findings from a preceding /review-pr-g or /review-pr-fixes-g and classify it as skip, merge, or add. Invoked per note -- the user queues one call per observation while the agent reviews. Use after /review-pr-g or /review-pr-fixes-g, before /draft-review-g."
disable-model-invocation: true
---

# Triage Finding

Given a single user-authored review note (passed as the invocation argument), evaluate it against the agent's raw findings from the preceding `/review-pr-g` or `/review-pr-fixes-g`, and decide: skip, merge, or add.

This skill is part of the review pipeline. The user queues `/triage-finding-g` invocations while the agent reviews the PR. Each invocation is processed sequentially after the review finishes, building up a consolidated findings list for `/draft-review-g`.

## Input

The user's observation as free text. May include a file path, line reference, or just a prose description of the issue.

## Steps

### 1. Validate context

Verify the conversation contains raw findings from a preceding `/review-pr-g` or `/review-pr-fixes-g`. If not, tell the user and stop.

### 2. Parse the note

Extract the user's observation:

- **File path** -- if the note mentions a specific file.
- **Line range** -- if the note references specific lines.
- **Concern** -- the issue being raised, in the user's words.

If the note is too vague to act on (no file, no line, no identifiable concern), ask the user to clarify and stop.

### 3. Match against existing findings

Search the agent's raw findings (and any findings added by previous `/triage-finding-g` invocations in the same conversation) for semantic overlap -- same file/line area, same concern. Classify:

- **Skip** -- The note duplicates an existing finding or isn't actionable. State which finding it duplicates and why.
- **Merge** -- The note adds context, evidence, or a better framing to an existing finding. Show the enriched finding with the user's addition integrated.
- **Add** -- The note identifies a genuine issue the agent missed. Create a new raw finding (file, line, severity, description) from the note.

### 4. Present the decision

Show the classification and its rationale:

- **Skip**: "Skipped -- duplicates finding N (same concern about X in `file.ts:42`)."
- **Merge**: "Merged into finding N -- added your observation about Y." Show the enriched finding.
- **Add**: "Added as new finding -- [Severity] `file.ts:42-48`: description." Show the new raw finding.

The user can override the decision in a follow-up message.

### 5. Update the findings list

Apply the decision to the conversation's running findings list. The next `/triage-finding-g` invocation (or `/draft-review-g`) will see the updated list.
