---
name: write-repro-steps
description: >-
  Investigates a Bug or Escape Defect work item and its surrounding context to produce concrete,
  minimal, accurate reproduction steps grounded in codebase evidence. Use when given a bug or
  escape defect that lacks clear or verified reproduction steps.
disable-model-invocation: true
---

# Write Repro Steps

Given a Bug or Escape Defect work item, investigate the surrounding context and codebase to produce concrete, minimal, accurate reproduction steps. The skill authors the steps only -- use `/reproduce-bug` as a follow-up to verify them in the running application.

## Input

Accept **any** of the following:

1. **Ticket reference** -- an Azure DevOps work item ID (e.g. `12345`) or full URL. The work item must be of type **Bug** or **Escape Defect**.
2. **Ticket reference + supplementary text** -- the text supplements the ticket. Use it to fill gaps the ticket leaves open, but do not let it contradict the ticket fields.

If no ID is provided, ask the user and stop.

## Steps

### 0. Enter Plan mode

Require **Plan** mode following the **mode-gate** skill. Steps 1--6 are read-only investigation and authoring. The user will switch to Agent mode for the apply step.

### 1. Gather work item context

Apply the **work-item-context** skill to build the full picture:

- Work item fields (title, type, state, description, repro steps, acceptance criteria).
- Related work items (parent, children, related, predecessors).
- Linked PRs and their status (diffs reveal what code paths are involved).
- Comments and discussions (often contain ad-hoc reproduction details not captured in fields).
- Hyperlinks and wiki pages referenced in the description.
- File attachments -- download screenshots and note video URLs for reference.

From the fetched fields, extract:

- **Existing repro steps**: from `Microsoft.VSTS.TCM.ReproSteps`, the description, or comments.
- **Org**: from `Custom.Org` (fall back to `manual` if absent).
- **Environment**: from `Microsoft.VSTS.CMMI.FoundInEnvironment`.
- **Work item type**: Bug vs Escape Defect -- this determines whether escape-point analysis applies.

Present the structured context summary to the user before proceeding.

### 2. Assess existing information

Evaluate the current repro information against these quality dimensions:

| Dimension | What to check |
|-----------|---------------|
| **Completeness** | Are all phases covered: preconditions, steps, expected behaviour, actual behaviour? |
| **Specificity** | Are steps discrete single-actions, or vague paragraphs combining multiple actions? |
| **Starting state** | Is a known, clean starting state documented (logged-out, fresh page, specific user role)? |
| **Environment clarity** | Is the environment, org, build version, or browser documented? |
| **Reproducibility** | Is a frequency noted (e.g. "3 out of 5 attempts"), or is the issue assumed deterministic? |

For **Escape Defect** work items, additionally assess:

- **Found-in environment**: where was the defect discovered (production, staging, UAT)?
- **Escape point**: which quality gate should have caught it (unit tests, integration tests, QA, code review, CI pipeline)?
- **Detection method**: how was it detected (customer report, monitoring alert, manual testing)?

Present a gap summary listing what is missing or unclear. If the existing steps are already concrete, specific, and complete, inform the user and ask whether to proceed or stop.

### 3. Investigate the codebase

Search the codebase to ground the reproduction steps in code reality. This ensures the authored steps reflect actual application behaviour rather than assumptions.

#### Parallel investigation

When the agent supports parallel subagent execution, prefer this approach:

1. Decompose the investigation into 2--3 focused questions. Typical decomposition:
   - Which endpoints, pages, or components are involved in the reported behaviour?
   - What preconditions does the code require (authentication, data state, feature flags, configuration)?
   - What is the failure path -- where does the code diverge from expected behaviour?
2. Spawn one read-only **explorer** subagent per question, providing:
   - The specific question to answer.
   - A directory or file scope hint derived from the work item's description and error details.
3. Collect all subagent results before proceeding.

#### Sequential fallback

If parallel execution is unavailable, proceed sequentially:

1. Based on the work item's description and any existing repro steps, search for the affected area (endpoints, handlers, UI components).
2. Read the relevant code to understand the current implementation.
3. Trace the execution path from user action to the point where the problem manifests.
4. Identify preconditions the code enforces (auth checks, required data, env-specific branches).

Present findings:

```
## Codebase Context: #<ID> -- <Title>

### Affected Area

<Which modules, files, and functions are involved>

### User-Facing Entry Point

<The page, endpoint, or UI component the user interacts with to trigger the bug>

### Preconditions (from code)

<Auth requirements, data state, feature flags, environment configuration>

### Failure Path

<How the code diverges from expected behaviour -- what goes wrong and where>
```

### 4. Author reproduction steps

Synthesise the work item context (step 1), gap analysis (step 2), and codebase evidence (step 3) into structured reproduction steps.

Follow these authoring principles:

- **One action per step.** Each numbered step describes a single, discrete user action. Do not combine navigation, input, and submission into one step.
- **Use interface labels.** Reference buttons, fields, menus, and pages by their visible labels in the UI -- not by internal component names or CSS selectors.
- **Start from a known state.** The first step must establish a clean starting point (e.g. "Log in as `<role>` user on `<org>`" or "Navigate to `<URL>` in a new browser session").
- **Separate setup from trigger.** Mark which steps are setup (reaching the right state) and which are the trigger (the action that causes the bug).
- **Be environment-specific.** If the bug depends on a particular org, environment, or data state, say so explicitly in the preconditions.

Produce the steps in this structure:

```
## Reproduction Steps: #<ID> -- <Title>

### Preconditions

- **Environment**: <environment name, or "any" if not environment-specific>
- **Org**: <org name, or "any">
- **User role**: <required role or permissions>
- **Data state**: <any data that must exist before starting, or "none">
- **Feature flags**: <relevant flags and their required values, or "none">
- **Browser / client**: <specific browser or client requirements, or "any">

### Setup

1. <Action to reach the starting point>
2. ...

### Trigger

3. <Action that triggers the bug>
4. ...

### Expected behaviour

<What should happen after the trigger steps>

### Actual behaviour

<What happens instead -- include error messages, codes, or trace IDs if known>

### Reproducibility

<Frequency if known, e.g. "deterministic", "3 out of 5 attempts", or "unknown">
```

For **Escape Defect** work items, append an additional section:

```
### Escape Point

- **Found in**: <environment where the defect was detected>
- **Detection method**: <how it was found -- customer report, monitoring, manual testing>
- **Missed by**: <which quality gate should have caught it -- unit tests, integration tests, QA cycle, code review, CI>
- **Gap**: <brief explanation of why the gate missed it, if determinable>
```

### 5. Minimise

Review each step critically:

1. For each step, ask: "If I remove this step, does the bug still trigger?"
2. Remove any step whose removal does not affect reproducibility.
3. Collapse consecutive navigation steps only if they traverse a single, unambiguous path (e.g. "Navigate to Settings > Accounts" is acceptable; "Navigate to Settings, filter by type, and select the account" is not).
4. Ensure setup steps are still clearly separated from trigger steps after minimisation.

The goal is the shortest path from a known state to the bug. Fewer steps mean faster verification and less ambiguity.

### 6. Present for approval

Present the final drafted reproduction steps to the user. Ask the user to **approve**, **modify**, or **reject**.

- If **modified**: incorporate the user's changes and re-present.
- If **rejected**: ask what was wrong and return to step 4.
- If **approved**: proceed to step 7.

Recommend running `/reproduce-bug` as a follow-up to verify the steps in the running application.

### 7. Apply

Once the user approves, require **Agent** mode following the **mode-gate** skill, then:

1. Update the work item's `Microsoft.VSTS.TCM.ReproSteps` field with the approved reproduction steps (formatted as HTML) via `update_work_item`.
2. For **Escape Defect** work items: if the escape-point information is not already captured in a dedicated field, add a work item comment documenting the escape-point analysis from step 4.

Print the work item **ID** and confirm the update.

### 8. Evolve

Follow the **continuous-improvement** skill.
