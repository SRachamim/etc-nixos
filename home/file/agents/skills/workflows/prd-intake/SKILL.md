---
name: prd-intake
description: >-
  Transforms a raw PRD, BRD, or ADO work item into a structured analysis
  document with extracted requirements, affected modules, test mappings,
  a pre-filled tech design, and a commit-level execution plan. Use when
  given a plain-English product requirements document that needs translating
  into actionable input for planning and implementation skills.
disable-model-invocation: true
---

# PRD Intake

Given a PRD (any format -- ADO work item, markdown file, inline text), produce a self-contained analysis document that a fresh agent session can pick up and implement from. The document extracts structured requirements, identifies affected modules, maps acceptance criteria to tests, pre-fills a tech design, and drafts a commit-level execution plan.

This skill bridges raw product requirements to the structured input that `/plan` and the **plan-execution** skill expect. It does not implement the feature -- it produces the plan.

## Input

Accept **any** of the following:

1. **ADO work item ID or URL** -- fetch the work item and all linked context.
2. **File path** -- read a markdown, text, or other document file.
3. **Inline text** -- use the pasted PRD text directly.
4. **Context inference** -- if no explicit input is provided, follow the **resolve-current-work-item** skill to derive the source from the current branch or ADO association.

When multiple inputs are provided, they supplement each other.

## Steps

### 0. Enter Plan mode

Require **Plan** mode following the **mode-gate** skill. The entire analysis (steps 1--8) is read-only. The user switches to Agent mode only when handing off the output document to `/plan` or **plan-execution** for implementation.

### 1. Resolve the input

Gather the raw PRD material:

- **ADO work item**: apply the **work-item-context** skill to build the full picture -- title, description, acceptance criteria, relations, comments, linked documents. Follow hyperlinks (wiki pages, external URLs, attached files) to gather supplementary material.
- **File path**: read the file contents.
- **Inline text**: use the provided text as-is.
- **Context inference**: resolve and then treat as an ADO work item.

Restate the feature's goal in one paragraph before proceeding. Confirm understanding with the user if the intent is ambiguous.

### 2. Extract structured requirements

Parse the PRD into these categories, assigning each requirement a unique ID for traceability:

| Category | ID prefix | What it captures |
|----------|-----------|------------------|
| Functional requirements | FR-N | What the system must do |
| Non-functional requirements | NFR-N | Performance, security, accessibility, observability |
| Acceptance criteria | AC-N | Conditions that define "done" |
| Constraints | C-N | Technical or business limitations |
| Assumptions | A-N | Things presumed true but not verified |
| Out-of-scope | OS-N | Items explicitly excluded from this work |

When the PRD is ambiguous, flag items as **needs clarification** rather than guessing. Collect all open questions -- they will appear in the final document.

### 3. Research prior art

Apply the **prior-art-research** skill. Search for established patterns that address the problem domain, with preference for functional and DDD solutions. Summarise findings that inform the tech design and approach in step 6.

### 4. Identify affected packages and modules

Explore the codebase to identify which packages, modules, and layers the feature touches:

- Examine the repository structure dynamically -- discover packages, apps, and libraries from the file tree rather than hardcoding paths.
- For each affected area, explain **why** it is affected and **what** changes are expected.
- Flag cross-package or cross-layer changes that increase complexity or risk.
- Note new modules that need to be created and where they fit in the existing structure.
- Consult workspace rules for module structure conventions (e.g. `module-anatomy`, if present).

When the scope is broad, use parallel exploration (Task tool with explore subagents) to examine different areas of the codebase concurrently.

### 5. Map acceptance criteria to tests

For each acceptance criterion (AC-N), produce concrete test cases:

| AC | Test description | Expected behaviour | Edge cases |
|----|------------------|--------------------|------------|

This mapping feeds the TDD workflow -- tests are defined before implementation. Structure tests following the **test-driven-development** skill. Each test should be specific enough that an agent can write it without further clarification.

### 6. Pre-fill tech design

Produce a draft tech design section with these fields:

- **Context** -- summarised from the PRD and prior-art research.
- **Goals** -- derived from functional requirements (FR-N).
- **Non-goals** -- derived from out-of-scope items (OS-N).
- **Proposed approach** -- initial assessment informed by prior art (step 3) and codebase exploration (step 4). Reference specific patterns, modules, and extension points.
- **Affected areas** -- from step 4, with expected changes per area.
- **Open questions** -- from step 2 plus any that emerged during analysis.

If the workspace has a tech design skill or template (e.g. a workspace-level tech design command), structure the output to be compatible with its expected input format. The skill does not depend on any workspace-level skill existing -- the tech design section is useful on its own.

When the proposed approach has a credible alternative that would fundamentally change the execution plan structure, suggest invoking `/compare-approaches` to resolve the fork before finalising the execution plan in step 7.

### 7. Produce execution plan

Group the work into **phases**, then break each phase into commits. This two-level structure -- phases containing commits -- gives the implementing agent both a high-level roadmap and granular steps.

#### Phases

Each phase is a bounded unit of work that ends with a verifiable gate -- a testable checkpoint the agent (or a human) can confirm before proceeding. Aim for 3--7 phases. A phase typically maps to one area of the codebase or one slice of functionality.

For each phase, specify:

- **Scope** -- what this phase delivers.
- **Dependencies** -- which prior phases must be complete.
- **Definition of done** -- a concrete, testable condition (e.g. "all tests pass", "endpoint returns 200 with correct shape", "type-checks clean"). This is the verification gate.

#### Commits within phases

Within each phase, list commits using the same format as the `/plan` skill output:

| # | Type | Title | What | Key Files | Technique | Validation |
|---|------|-------|------|-----------|-----------|------------|

Design each commit following the **commit-conventions** skill:

- One logical change per commit.
- Tests belong with the code they test (or in a preceding commit when adding test infrastructure).
- Refactoring commits precede the feature commits they enable.
- Each commit is independently valid -- compiles and passes tests.
- Documentation updates go in the same commit that makes them stale.

Each commit specifies:

- **What** changes and why.
- **Key Files** expected to be touched.
- **Validation** -- a concrete verification step (test command, type check, manual check). Reference workspace rules for available commands.

Include non-commit actions where needed (e.g. creating follow-up tasks, updating work item state).

This is a first draft -- less precise than what `/plan` produces after deep codebase analysis. The intent is to give enough structure that either:

1. The user feeds the document to `/plan` for refinement with deeper codebase analysis, or
2. A sufficiently detailed plan is executed directly via **plan-execution**.

### 8. Present the output document

Assemble all sections into a single self-contained markdown document. Apply the **objective-communication** skill to all prose.

The document must be complete enough that a fresh agent session (with no prior context) can pick it up and implement from it. Treat the reader as a newcomer to the repository. Concretely, the document must include:

- The feature's goal and requirements (not just IDs -- the full text).
- Key file paths, types, and interfaces the implementation will touch.
- Exact validation commands (not "run tests" -- the specific command).
- Decisions made during analysis, so a fresh session does not re-litigate them.

Output format:

```
## PRD Intake: <Feature Title>

**Source**: <ADO link, file path, or "inline text"> | **Date**: <today>

### Goal

<1--3 sentence summary of the feature and its purpose>

### Requirements

#### Functional Requirements

| ID | Requirement | Notes |
|----|-------------|-------|

#### Non-functional Requirements

| ID | Requirement | Notes |
|----|-------------|-------|

#### Acceptance Criteria

| ID | Criterion | Status |
|----|-----------|--------|

#### Constraints

| ID | Constraint |
|----|------------|

#### Assumptions

| ID | Assumption |
|----|------------|

#### Out of Scope

| ID | Item |
|----|------|

### Prior Art

<Bullet summary from step 3 -- patterns found, best fit, adaptations needed>

### Affected Modules

| Package / Module | Why affected | Expected changes | Risk |
|------------------|--------------|------------------|------|

### Test Mapping

| AC | Test description | Expected behaviour | Edge cases |
|----|------------------|--------------------|------------|

### Tech Design Draft

**Context**: ...
**Goals**: ...
**Non-goals**: ...
**Proposed approach**: ...
**Affected areas**: ...

### Execution Plan

#### Phase 1: <Name>

**Scope**: ...
**Dependencies**: None
**Definition of done**: <testable condition>

| # | Type | Title | What | Key Files | Technique | Validation |
|---|------|-------|------|-----------|-----------|------------|

#### Phase N: <Name>

...

### Decision Log

| # | Decision | Rationale | Alternatives considered |
|---|----------|-----------|------------------------|

### Open Questions

| # | Question | Source | Impact |
|---|----------|--------|--------|
```

### 9. Iterate

Wait for the user to review, ask questions, or request changes. When the document is approved, suggest next steps:

- **Refine**: feed the document to `/plan` for deeper codebase analysis and a tighter commit sequence.
- **Execute**: if the execution plan is detailed enough, proceed directly via **plan-execution**.
- **Delegate**: if the workspace has a routing skill (e.g. a developer skill that selects implementation patterns by feature type), note the recommended route.

### 10. Evolve

Follow the **continuous-improvement** skill.
