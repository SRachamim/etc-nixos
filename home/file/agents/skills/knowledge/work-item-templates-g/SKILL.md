---
name: work-item-templates-g
description: "Comprehensive templates for Bug, Task, and User Story work items with complexity tiers, ADO field mapping, quality gates, and acceptance criteria format guidance. Loaded when the agent creates or edits work items in Azure DevOps."
---

# Work Item Templates

Templates, ADO field mapping, and quality gates for Bug, Task, and User Story work items. Each type has three complexity tiers with observable selection signals.

## Prerequisite

**objective-communication-g** governs all work item text (priority 1 per the **delivered-text-g** ladder). These templates provide structure -- fill-in-the-blank skeletons. When a template section conflicts with an objective-communication principle, the principle wins.

For title patterns, see also **communication-templates-g** sections 7--8 (quick reference). This skill is the comprehensive source.

## Tier selection protocol

Select the tier based on **observable signals**, not subjective judgment. Check the "When" criteria for each tier under each work item type. When signals span two tiers, pick the higher tier -- over-specifying is cheaper than under-specifying.

---

## 1. Bug

### ADO field mapping

| Content | ADO field | Notes |
|---------|-----------|-------|
| Title | `System.Title` | Symptom + where + when |
| Repro steps, expected/actual, environment, evidence | `Microsoft.VSTS.TCM.ReproSteps` | All reproduction content lives here exclusively |
| Root-cause hypothesis, fix approach | `System.Description` | Only for Investigated tier -- do NOT duplicate repro content here |
| Severity | `Microsoft.VSTS.Common.Severity` | 1-Critical, 2-High, 3-Medium, 4-Low |
| Priority | `Microsoft.VSTS.Common.Priority` | 1--4 (business urgency, not technical impact) |
| Found in build | `Microsoft.VSTS.Build.FoundIn` | Build/version where observed, if known |
| Resolved in build | `Microsoft.VSTS.Build.IntegratedInBuild` | Set after fix merges |
| Area / Iteration | `System.AreaPath`, `System.IterationPath` | Per team defaults |
| Parent | Parent link | Link to parent User Story |

**Rule:** severity (intrinsic technical impact) and priority (extrinsic business urgency) are independent axes. A critical-severity bug in an internal admin tool may be low priority. Set both explicitly.

### Simple

**When:** clear reproduction, single observable symptom, no investigation done yet, cause likely obvious from context.

**Title:**

```
<Observable symptom> <where it occurs> <when/trigger>
```

**ReproSteps:**

```
**Steps to reproduce**
1. <Starting state>
2. <Action>
3. <Action that triggers the bug>

**Expected:** <what should happen>

**Actual:** <what happens instead>
```

Omit "Additional context" and "Environment" sections when the user's input doesn't cover them.

### Standard

**When:** reproduction requires multiple steps, involves specific environment conditions, or affects a non-obvious area. The default tier when severity is 2-High or above, or when the symptom has multiple manifestations.

**Title:**

```
<Observable symptom> <where it occurs> <when/trigger>
```

**ReproSteps:**

```
**Environment**
<OS, browser, build version, network conditions, relevant config>

**Steps to reproduce**
1. <Starting state -- explicit, verifiable>
2. <Action>
3. <Action>
4. <Triggering action>

**Expected:** <what should happen>

**Actual:** <what happens instead>

**Frequency:** <Always / Sometimes / Once / Unable to determine>

**Evidence**
<Console errors, network logs, screenshots, correlation IDs -- attach binaries as ADO attachments>
```

### Investigated

**When:** root cause is known or strongly suspected. A fix approach exists. This tier adds `System.Description` for analysis content.

**Title:**

```
<Observable symptom> <where it occurs> <when/trigger>
```

**ReproSteps:** same as Standard tier.

**Description** (`System.Description`):

```
**Root cause**
<What is going wrong in the code and why -- grounded in observable evidence, not speculation>

**Proposed fix**
<What to change and why this approach -- alternatives considered briefly if relevant>

**Affected areas**
<What else might break or need updating>
```

### Quality gate: 8-field completeness

Before submitting a Bug, verify these fields are populated:

1. Title -- observable symptom, not implementation cause
2. Severity -- inferred from impact, defaulting to 3-Medium when unclear
3. Priority -- set independently from severity
4. ReproSteps -- numbered steps from a known starting state
5. Expected behavior -- always present, infer from context if not stated
6. Actual behavior -- always present
7. Parent User Story -- linked (per **create-work-item-g** rules)
8. Area/Iteration -- per team defaults

### Anti-patterns

| Anti-pattern | Principle violated |
|---|---|
| Title: "Bug in order total calculation" | Concretise -- no observable symptom; "Bug" is the item type |
| Mixing severity and priority into one field | Objectivity -- conflating two independent dimensions |
| Describing root cause instead of observed behavior in Actual | Anti-rationalism -- cause is hypothesis, symptom is fact |
| Missing starting state in repro steps | Self-containment -- reader can't reproduce |
| Environment buried in prose | Structure -- queryable data in dedicated section |
| `TBD` in severity or priority at submission | Delimit -- defer decisions the reader needs now |

---

## 2. Task

### ADO field mapping

| Content | ADO field | Notes |
|---------|-----------|-------|
| Title | `System.Title` | Verb + deliverable + context |
| Goal, context, scope, done criteria | `System.Description` | All task information lives here |
| Hours estimate | `Microsoft.VSTS.Scheduling.OriginalEstimate` | Hours, not story points |
| Activity type | `Microsoft.VSTS.Common.Activity` | Development, Testing, Design, Documentation |
| Remaining work | `Microsoft.VSTS.Scheduling.RemainingWork` | Updated during sprint |
| Area / Iteration | `System.AreaPath`, `System.IterationPath` | Per team defaults |
| Parent | Parent link | Link to parent User Story |
| Dependencies | Predecessor/Successor links | Blocked-by relationships |

**Rule:** Tasks use hours (`OriginalEstimate`, `RemainingWork`), not story points. Story points belong on User Stories.

### Simple

**When:** under 4 hours, single layer (one file or one module), 1--2 done criteria. The cause and approach are obvious from the title alone.

**Title:**

```
<Verb> <what to deliver> <context/parent scope>
```

**Description:**

```
<What needs to happen -- the concrete deliverable>

**Done when:**
- <Observable completion condition>
- <Observable completion condition>
```

### Standard

**When:** 4--8 hours, touches 2--3 files or crosses one module boundary, requires approach notes. The default tier.

**Title:**

```
<Verb> <what to deliver> <context/parent scope>
```

**Description:**

```
**Goal:** <what this task achieves -- the deliverable>

**Context:** <why it matters or what triggered it -- link to parent>

**Approach:** <how to accomplish it -- key decisions, not a step-by-step plan>

**Scope:** <boundaries or constraints -- what is excluded>

**Done when:**
- <Observable completion condition>
- <Observable completion condition>
- <Observable completion condition>
```

### Complex (must decompose)

**When:** over 8 hours, spans multiple architectural layers (UI + API + DB), or contains significant unknowns. A complex task **must be decomposed** into subtasks before assignment -- each subtask should be under one day of work.

If the agent detects a Complex task, it should recommend decomposition:

1. Identify the distinct layers or steps.
2. Create one Simple or Standard subtask per layer/step.
3. Link subtasks as children of the original task (or its parent story).
4. The original task becomes a container -- not assigned for direct work.

### Quality gate: SMART

Before submitting a Task, verify it passes SMART:

| Letter | Check | Fail action |
|--------|-------|-------------|
| **S**pecific | Title names a concrete deliverable, not a vague area | Rewrite title with verb + object |
| **M**easurable | At least one "Done when" condition is observable | Add testable completion criteria |
| **A**chievable | Estimate is under 8 hours (single task) | Decompose into subtasks |
| **R**elevant | Parent User Story is linked | Find or create the parent story |
| **T**ime-boxed | `OriginalEstimate` is set | Estimate before assignment |

### Anti-patterns

| Anti-pattern | Principle violated |
|---|---|
| Task without parent story link | Structure -- orphan work, broken rollup |
| Task written as user story ("As a developer...") | Delimit -- wrong item type; tasks are technical decomposition |
| No done criteria ("just do the thing") | Concretise -- no observable completion |
| Task spanning multiple architectural layers | Delimit -- should decompose |
| Using Story Points on Tasks | Objectivity -- wrong estimation unit (use hours) |
| Title that's a file path with no verb | Motivate -- no action, no outcome |
| "Investigate X" without time-box or exit criteria | Delimit -- open-ended work; use a time-boxed spike |

---

## 3. User Story

### ADO field mapping

| Content | ADO field | Notes |
|---------|-----------|-------|
| Title | `System.Title` | Verb + user-facing outcome + scope |
| Problem/opportunity, scope, non-goals, constraints | `System.Description` | Context and boundaries -- NOT acceptance criteria |
| Acceptance criteria | `Microsoft.VSTS.Common.AcceptanceCriteria` | Dedicated field -- NOT in description |
| Story points | `Microsoft.VSTS.Scheduling.StoryPoints` | Relative estimate |
| Priority | `Microsoft.VSTS.Common.Priority` | 1--4 |
| Business value | `Microsoft.VSTS.Common.BusinessValue` | If the field is configured |
| Area / Iteration | `System.AreaPath`, `System.IterationPath` | Per team defaults |
| Parent | Parent link | Link to parent Feature or Epic |

**Rule:** acceptance criteria go in the `AcceptanceCriteria` field, not in `Description`. Description holds context (problem, scope, constraints); AC holds verifiable conditions. This keeps AC queryable and prevents drift between context prose and testable conditions.

### Simple

**When:** 1--3 story points, single behavioral change, 2--3 independent acceptance criteria. The user need is obvious and self-contained.

**Title:**

```
<Verb> <user-facing outcome> <scope/context>
```

**Description:**

```
<What the user needs and why -- the pain point or value gap>
```

**AcceptanceCriteria:**

```
- [ ] <Observable condition 1>
- [ ] <Observable condition 2>
- [ ] <Observable condition 3>
```

Checklist format. Each criterion is independently verifiable.

### Standard

**When:** 3--5 story points, involves context that isn't obvious from the title, 3--5 acceptance criteria. May include one state-dependent flow.

**Title:**

```
<Verb> <user-facing outcome> <scope/context>
```

**Description:**

```
<Problem or opportunity -- why this work matters to users.
What pain point or value gap exists.>

**Scope**
<What is included and what is explicitly excluded.
Boundaries the implementer should respect.>

**Constraints**
<Technical, organizational, or regulatory restrictions
that limit the solution space.>
```

**AcceptanceCriteria:**

Hybrid format -- checklist for independent rules, Given/When/Then for the core behavioral flow:

```
**Core flow**
Given <precondition/state>
When <user action or system event>
Then <observable outcome>

**Additional conditions**
- [ ] <Independent validation rule>
- [ ] <Edge case handling>
- [ ] <Non-functional condition -- e.g. response time, accessibility>
```

### Complex (must split)

**When:** 5+ story points, spans multiple bounded contexts, AC list exceeds 5 items, or contains significant unknowns. A complex story **must be split** into vertical slices before entering a sprint.

If the agent detects a Complex story, it should recommend splitting:

1. Apply vertical splitting patterns: by workflow step, by business rule, by data variation, by happy/sad path.
2. Each slice must be independently valuable (passes INVEST).
3. Create one Simple or Standard story per slice.
4. Link slices to the same parent Feature/Epic.
5. If significant unknowns exist, create a time-boxed Spike first.

### Quality gate: INVEST

Before submitting a User Story, verify it passes INVEST:

| Letter | Check | Fail action |
|--------|-------|-------------|
| **I**ndependent | Can be developed without depending on other stories in the same sprint | Extract the dependency into a separate story or reorder |
| **N**egotiable | States the need, not the solution -- implementation details are absent | Remove implementation prescriptions from description and AC |
| **V**aluable | Delivers user-visible value, not just technical enablement | Reframe around the user outcome; if purely technical, make it a Task |
| **E**stimable | Team can estimate with reasonable confidence | Add context or spike first to reduce unknowns |
| **S**mall | Fits in one sprint; ideally 1--5 story points | Split into vertical slices |
| **T**estable | Every AC is observable and has a clear pass/fail | Rewrite vague AC with concrete conditions |

### Anti-patterns

| Anti-pattern | Principle violated |
|---|---|
| "As a user, I want a button" | Motivate -- describes solution, not user need |
| "As a developer, I want to refactor..." | Delimit -- technical work belongs in a Task |
| AC in description instead of dedicated field | Structure -- AC becomes unqueryable, drifts from context |
| AC: "works correctly" | Concretise -- not observable or testable |
| 10+ AC items | Delimit -- story should split |
| Horizontal splits (UI-only, API-only) | INVEST (Valuable) -- not independently valuable |
| AC that describes database operations or internal API calls | Anti-rationalism -- AC must pass the black-box test (see **requirements-classification-g**) |
| Copying a PRD verbatim into description | Delimit -- story scope is narrower than PRD scope |
| Missing scope boundaries | Self-containment -- implementer can't determine what's excluded |

---

## Acceptance criteria format guide

Choose the AC format based on the nature of the conditions, not the story complexity.

| Format | When to use | Example |
|--------|-------------|---------|
| **Checklist** | Independent rules, validation constraints, permission checks, NFRs | `- [ ] Order total displays with 2 decimal places` |
| **Given/When/Then** | State-dependent behavior, branching flows, permission-gated actions | `Given an expired session, When the user submits, Then a re-auth prompt appears` |
| **Hybrid** (recommended default) | Most Standard-tier stories: Given/When/Then for the core flow, checklist for secondary rules | See Standard tier template above |

### AC quality rules

Every acceptance criterion must pass the black-box test from **requirements-classification-g**:

> Could a user, tester, or product manager verify this without knowing the internal architecture?

- **Yes** -- valid AC.
- **No** -- move it to a task description or tech design note.

Additional checks:
- **Behavioral** -- describes what, not how
- **Observable** -- verifiable from outside the system
- **Testable** -- clear pass/fail result
- **Independent** -- one condition per criterion
- **Story-scoped** -- specific to this unit of work

---

## Decomposition triggers

Any one of these signals means the work item must be broken down before entering a sprint:

| Signal | Applies to | Action |
|--------|-----------|--------|
| Cannot estimate with confidence | All types | Spike first, then create refined items |
| AC list exceeds 5 items | User Story | Split into vertical slices |
| Spans multiple bounded contexts | User Story, Task | One item per context |
| Spans multiple architectural layers | Task | One subtask per layer |
| Estimate exceeds 8 hours | Task | Decompose into subtasks |
| Estimate exceeds 5 story points | User Story | Split into slices |
| Contains "and" connecting independent concerns | All types | Separate items |

## Splitting patterns (User Stories)

When a story must split, apply these vertical patterns in order of preference:

1. **By workflow step** -- each step in a user flow becomes its own story
2. **By business rule** -- each rule or validation becomes its own story
3. **By data variation** -- handle one data type/format per story
4. **By happy/sad path** -- happy path first, error handling as follow-up stories
5. **By operation** -- CRUD: start with Read, then Create, then Update, then Delete

Horizontal splits (frontend-only, backend-only) violate INVEST (Valuable) and should be avoided.

## Related skills

- **objective-communication-g** -- principles that govern all template text (priority 1)
- **communication-templates-g** -- quick-reference title patterns (sections 7--8)
- **requirements-classification-g** -- black-box test for AC, FR/NFR classification, out-of-scope precision
- **create-bug-g**, **create-task-g**, **create-user-story-g** -- workflow skills that use these templates
- **create-work-item-g** -- shared creation plumbing (iteration, parent linking, approval)
- **effort-estimation-g** -- estimation methodology for hours and story points
