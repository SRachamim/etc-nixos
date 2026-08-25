---
name: extract-requirements-g
description: Extracts structured requirements (FR/NFR/AC/C/A/OS) from a work item context, textual description, or design document. Called by plan-g (step 2) -- not invoked directly by the user.
disable-model-invocation: true
---

# Extract Requirements

Given a specification source -- a work item context, a textual description, or a design document -- parse it into categorised requirements. The output feeds into commit planning, verification strategy, and traceability.

This file is a shared skill. It is referenced by **plan-g** (step 2) for all input types. It is not invoked directly by the user.

## Inputs (provided by the calling skill)

Exactly one of the following:

| Input | Description |
|-------|-------------|
| **workItemContext** | The structured summary from **work-item-context-g** -- title, type, state, description, acceptance criteria, repro steps, comments, related work items, linked PRs, supplementary material. |
| **textDescription** | A plain-language description of the feature, bug, or task provided by the user. |
| **designDoc** | A tech design, plan output, or inline specification describing the desired architecture. |

## Output

| Field | Description |
|-------|-------------|
| **requirements** | A table of categorised requirements with unique IDs (FR-N, NFR-N, AC-N, C-N, A-N, OS-N). |
| **openQuestions** | Items flagged as ambiguous or needing clarification. |

## Steps

### 1. Collect candidate statements

Scan the input for requirement-bearing text. The sources depend on the input type:

**Work item context** -- where to look depends on the work item type:

| Work item type | Primary sources | Secondary sources |
|----------------|----------------|-------------------|
| **Bug** | Repro steps, description, acceptance criteria | Comments (decisions, scope clarifications) |
| **Task** | Description, acceptance criteria | Comments, parent story's AC |
| **User Story** | Acceptance criteria, description | Comments, child tasks |
| **Feature** | Description, acceptance criteria | Comments, child stories |

**Text description** -- parse the entire text. Look for statements about what the system should do, quality expectations, constraints, and scope boundaries.

**Design doc** -- extract goals, non-goals, requirements sections, and any acceptance criteria. Treat non-goals as out-of-scope items (OS-N).

For each source, extract individual statements -- one requirement per statement. Split compound sentences that contain multiple testable conditions.

### 2. Classify each statement

Apply the **requirements-classification-g** skill to every candidate statement. Use the black-box test:

> Could a user, tester, or product manager verify this statement without knowing the internal architecture?

Assign each statement to a category:

| Category | ID prefix | What it captures |
|----------|-----------|------------------|
| Functional requirement | FR-N | What the system must do (observable behaviour) |
| Non-functional requirement | NFR-N | Quality attributes (performance, security, accessibility, observability) |
| Acceptance criterion | AC-N | Conditions that define "done" for this work item |
| Constraint | C-N | Technical or business limitations imposed externally |
| Assumption | A-N | Things presumed true but not verified |
| Out of scope | OS-N | Items explicitly excluded |

Statements that fail the black-box test are design decisions -- do not include them in the requirements table. Note them separately so the calling skill can place them in the tech design or commit plan.

### 3. Apply source-specific extraction rules

Augment the raw extraction with rules specific to the input type. For **textDescription** and **designDoc** inputs, skip to step 4 -- the rules below apply only to work item context.

**Work item type-specific rules:**

**Bug:**
- The defect description becomes a negative FR: "The system incorrectly [observed behaviour]" or "The system fails to [expected behaviour]."
- The expected behaviour (from repro steps or description) becomes the positive FR: "The system must [correct behaviour]."
- Each repro step that describes a verifiable end state becomes an AC.
- If the bug mentions specific environments, browsers, or configurations, capture those as constraints (C-N).

**Task:**
- The task objective (from description) maps to one or more FRs.
- Explicit "done" criteria from the description or acceptance criteria map to ACs.
- If the task is scoped to a specific module or layer, note the boundary as a constraint (C-N).

**User Story:**
- Acceptance criteria from the work item map directly to ACs (reformat if needed to pass the black-box test).
- The story description ("As a... I want... so that...") maps to FRs.
- The "so that" clause may imply NFRs (e.g. "so that I can quickly find..." implies performance).

**Feature:**
- Description maps to high-level FRs.
- Child stories provide more granular FRs and ACs -- reference them by ID rather than duplicating.

### 4. Synthesise implicit requirements

Inputs often omit requirements that are implied by context. Check for:

- **Implicit NFRs**: Does the input mention or imply performance targets, security constraints, accessibility needs, or observability expectations? If so, make them explicit as NFR-N items. If not mentioned, do not invent them.
- **Implicit constraints**: For work items, does the parent story, iteration, or area path impose constraints (e.g. "must not break existing API consumers")? For text/design inputs, does the description mention boundaries or limitations? Check related context.
- **Implicit assumptions**: Are there unstated dependencies on other teams, services, or infrastructure? If the input assumes something that could be false, capture it as A-N.
- **Implicit out-of-scope**: If the input or surrounding context clarifies what is NOT part of this work, capture as OS-N.

Do not fabricate requirements. Only synthesise what is clearly implied by the available context.

### 5. Flag ambiguities

For any statement where:
- The intent is unclear
- Multiple interpretations are plausible
- The black-box test result is ambiguous
- A requirement references undefined terms or unknown systems

Mark it as **needs clarification** in the Notes column and add an entry to the open questions list.

### 6. Produce the output

Return the structured requirements in this format:

```
### Requirements

| ID | Category | Requirement | Notes |
|----|----------|-------------|-------|
| FR-1 | Functional | ... | ... |
| FR-2 | Functional | ... | ... |
| NFR-1 | Non-functional | ... | ... |
| AC-1 | Acceptance | ... | ... |
| C-1 | Constraint | ... | ... |
| A-1 | Assumption | ... | ... |
| OS-1 | Out of scope | ... | ... |

### Open Questions

| # | Question | Source |
|---|----------|--------|
| 1 | ... | FR-2 (ambiguous scope) |
```

Omit categories that have no entries. Number IDs sequentially within each category (FR-1, FR-2, ...; NFR-1, NFR-2, ...).

The calling skill decides how to present this output -- the shared skill does not format the final user-facing document.
