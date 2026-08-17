---
name: plan-from-prd-intake-g
description: >-
  Consumes a PRD Intake document and produces commit-level implementation
  plans for selected phases. Orchestrates phase selection, delegates to
  /plan-g logic per phase, and maintains traceability from commits back
  to PRD requirements. Use after /analyze-prd-g when the feature spans
  multiple PRs or phases.
disable-model-invocation: true
---

# Plan from PRD Intake

Consume a PRD Intake document (the output of `/analyze-prd-g`) and produce commit-level implementation plans for one or more phases. Each phase plan has the same rigour as a `/plan-g` output -- codebase exploration, design lenses, commit sequencing -- while maintaining traceability back to the PRD's functional requirements, acceptance criteria, and constraints.

This skill orchestrates multi-phase planning. For single-PR features, use `/plan-g` directly.

## Input

Accept **any** of the following:

1. **File path** -- path to a PRD Intake document (markdown file produced by `/analyze-prd-g`).
2. **Inline text** -- the PRD Intake document pasted directly.
3. **Conversation context** -- if neither file path nor inline text is provided, look for the most recent `/analyze-prd-g` output in the current conversation.

The PRD Intake document must follow the two-part structure: Part 1 (Feature Specification) and Part 2 (Agent Execution Context) with an Execution Plan containing phases.

## Steps

### 0. Enter Plan mode

Require **Plan** mode following the **mode-gate-g** skill. The entire workflow (steps 1--5) is read-only analysis. The user switches to Agent mode only when handing off an approved phase plan to **plan-execution-g** for implementation.

### 1. Resolve the PRD Intake document

Locate and parse the PRD Intake document:

- Validate it contains the expected structure: Goal, Requirements (with Stage column), Tech Design Draft, Execution Plan with phases.
- Extract the feature title, goal, and all requirement IDs (FR-N, NFR-N, AC-N, C-N).
- Extract the phase list from Part 2's Execution Plan section.

If the document is malformed or incomplete, report what is missing and ask the user to provide a corrected version or run `/analyze-prd-g` first.

### 2. Present phase overview

Summarise the phases for the user:

| Phase | Scope | Dependencies | Requirements (by Stage) | Definition of done |
|-------|-------|--------------|-------------------------|--------------------|

For each phase, list the requirement IDs mapped to it via the Stage column in the requirements tables. Ask the user which phase(s) to plan:

- **A specific phase** -- e.g. "Phase 2".
- **Multiple phases** -- e.g. "Phases 1 and 2".
- **All phases** -- plan sequentially with approval gates between each.
- **Next unplanned** -- the first phase that has not yet been planned in this conversation.

### 3. Plan the selected phase(s)

For each selected phase, produce a commit-level plan by executing the following sub-steps (mirroring `/plan-g` steps 2--7):

#### 3a. Gather phase context

Extract from the PRD Intake document:

- The phase's scope, key files, and definition of done.
- All requirements (FR/NFR/AC/C) whose Stage matches this phase.
- The Tech Design Draft's proposed approach and affected areas relevant to this phase.
- Prior Art findings that inform the approach.

#### 3b. Research prior art

Apply the **prior-art-research-g** skill, scoped to the phase's domain. Skip if the PRD Intake document's Prior Art section already covers the relevant patterns adequately -- reference it instead.

#### 3c. Understand the codebase

Explore the codebase following the same approach as `/plan-g` step 3:

- When parallel subagents are available, decompose into focused questions and spawn read-only explorers.
- When sequential, search and read key files in the affected area.
- Map extension points, boundaries, and the gap between current state and phase target.

#### 3d. Apply the design lenses

Apply the **design-lenses-g** skill using the **planning framing**. When multiple viable paths emerge with no clear winner, suggest invoking `/compare-approaches` before proceeding.

#### 3e. Draft the commit sequence

Design a sequence of commits following the **commit-conventions-g** skill. Apply the **decision-priorities-g** skill when choosing between alternatives.

For each commit, specify:

| Field | Description |
|-------|-------------|
| **#** | Sequence number |
| **Type** | `commit` or `action` |
| **Title** | Commit message following project conventions |
| **What** | Concise description of the change |
| **Key Files** | Files expected to be touched |
| **Technique** | Catalog refactoring technique (`--` for non-refactoring) |
| **Traceability** | Which FR/NFR/AC/C IDs this commit addresses |
| **Validation** | How to verify correctness |

#### 3f. Validate against phase gate

Confirm that executing all commits in sequence satisfies the phase's definition of done. If not, adjust the commit sequence.

### 4. Present the phase plan(s)

Output each phase plan in this format. Apply the **objective-communication-g** skill to all prose.

```
## Phase Plan: <Phase Name>

**Feature**: <Feature Title from PRD Intake>
**Phase**: <N> of <total> | **Scope**: <phase scope>
**Requirements addressed**: <comma-separated IDs, e.g. FR-1, FR-3, AC-2, NFR-1>
**Definition of done**: <from PRD Intake>

### Summary

<What this phase delivers and why it matters>

### Target State

<Description of the desired structure after this phase is complete>

### Design Lens

<Which 2--3 principles matter most for this phase and why>

### Implementation Steps

| # | Type | Title | What | Key Files | Technique | Traceability | Validation |
|---|------|-------|------|-----------|-----------|--------------|------------|

### Notes

<Risks, open questions, dependencies on other phases>
```

### 5. Iterate

Wait for the user to review, approve, or request changes. On approval, suggest next steps:

- **Execute**: implement the approved phase plan via **plan-execution-g** (switch to Agent mode).
- **Plan next phase**: proceed to the next unplanned phase.
- **Adjust**: modify the plan based on feedback.

When planning "all phases", present one phase at a time. After approval of one phase, proceed to the next. Do not batch all phase plans in a single output -- respect the context budget.

### 6. Evolve

Follow the **continuous-improvement-g** skill.
