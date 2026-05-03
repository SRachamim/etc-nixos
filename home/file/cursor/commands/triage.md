# Triage

Given a work item ID, deeply investigate it -- gathering context, examining the codebase, and proposing a fix approach -- before drafting the ADO field updates. Nothing is written until the user approves.

Unlike the **work-item-triage** skill (which performs a mechanical estimate-and-transition), this command adds investigation and fix-planning phases so the triage decision is informed by codebase evidence.

## Input

Accept an Azure DevOps work item ID (e.g. `12345`) or full URL.

If no ID is provided, ask the user and stop.

## Steps

### 0. Enter Plan mode

Require **Plan** mode following the **mode-gate** skill. All investigation, analysis, and drafting (steps 1--5) are read-only. The user will switch to Agent mode for the apply step.

### 1. Observe

Apply the **work-item-context** skill to build the full picture:

- Work item fields (title, type, state, description, acceptance criteria, repro steps).
- Related work items (parent, children, predecessors, successors).
- Linked PRs and their status.
- Comments and discussions.
- Hyperlinks and wiki pages referenced in the description.

Present the structured context summary to the user before proceeding.

### 2. Check for predecessor

Inspect the fetched relations for a **predecessor** link. If one exists, the work item is blocked and cannot be triaged yet:

1. Inform the user that the item has a predecessor dependency.
2. Recommend delegating to the **block-work-item** command, passing the current work item as the blocked ID and the predecessor as the blocker ID.
3. **Stop** -- do not proceed with investigation or triage.

### 3. Dry-debug

Investigate the codebase to understand the issue **without making any changes**:

1. Based on the work item's description, repro steps, and error details, search the codebase for the affected area (endpoints, functions, modules).
2. Read the relevant code to understand the current implementation.
3. Trace the execution path from input to the point where the problem occurs.
4. Identify the root cause or likely root cause. When certainty is low, state the hypothesis explicitly and note what is unknown.
5. Check existing test coverage in the affected area -- whether tests exist, whether they cover the failing scenario.

Spend enough time here to form a concrete understanding. Don't guess -- read the code.

Present findings:

```
## Investigation: #<ID> -- <Title>

### Affected Area

<Which modules, files, and functions are involved>

### Current Behaviour

<What the code does today, traced through the execution path>

### Root Cause (hypothesis)

<Why the bug occurs, with confidence level. "Unclear -- needs further investigation" is acceptable when evidence is insufficient.>

### Existing Coverage

<Relevant tests and whether they cover the failing scenario>

### Collateral Impact

<Other code paths or scenarios affected by the same root cause, if any. "None identified" if the issue is isolated.>
```

### 4. Dry-plan

Propose a fix approach **inline** -- do not create a plan file:

1. Design a high-level fix strategy.
2. Identify the files and modules that would need to change.
3. Note any preparatory refactoring that would be needed.
4. Flag risks and open questions.

Present the proposal:

```
## Proposed Fix: #<ID> -- <Title>

### Approach

<1--3 sentence description of the fix strategy>

### Key Changes

- <file/module>: <what changes and why>
- ...

### Risks / Open Questions

- ...
```

### 5. Draft triage updates

Compose the ADO field updates that **will** be applied, but do not apply them yet.

Follow the **estimation** skill for hours and confidence level, grounded in the codebase understanding from steps 3--4. Follow the **work-item-triage** skill for the required fields and their defaults.

If `OriginalEstimate`, `RemainingWork`, or `EstimationConfidenceLevel` are already set on the work item, carry the existing values forward and do not overwrite them.

Present the draft:

```
## Draft Triage: #<ID> -- <Title>

| Field | Value |
|-------|-------|
| State | Triaged |
| Priority | <value> |
| Business Priority | <value> |
| Version | <value> |
| Original Estimate | <hours> h |
| Remaining Work | <hours> h |
| Confidence Level | <level> |

### Estimation Rationale

<Brief explanation of how the estimate was derived, referencing the codebase evidence from steps 3--4>
```

> **Business Priority** uses a picklist -- use the label format, not bare numbers:
> `"1: Must Have"`, `"2: Should Have"`, `"3: Nice to Have"`, `"4: Technical"`.

Ask the user to **approve**, **modify**, or **reject** before proceeding. Do not apply any changes until explicit approval is given.

### 6. Apply

Once the user approves, require **Agent** mode following the **mode-gate** skill, then apply the triage updates via `wit_update_work_item` following the **work-item-triage** skill's update format (step 4 of that skill).

Print the work item **ID**, new **state**, **estimate (hours)**, and **confidence level**.

### 7. Evolve

Follow the **continuous-improvement** skill.