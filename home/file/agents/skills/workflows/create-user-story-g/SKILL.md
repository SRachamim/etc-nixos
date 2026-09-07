---
name: create-user-story-g
description: Creates a User Story work item in Azure DevOps from a free-form description of user need, with title, description, and acceptance criteria mapped to dedicated ADO fields. Use when the user wants to capture a user-facing need as a tracked User Story.
disable-model-invocation: true
---

# Create User Story

Create a new **User Story** work item in Azure DevOps, assigned to the current user on the next iteration.

## Steps

### 1. Understand the user need

The user provides a free-form description of a user-facing need, pain point, or capability gap. If the description is too vague to identify the user outcome (e.g. just "improve the dashboard"), ask a clarifying question. Otherwise, proceed -- do not ask the user to fill in structured fields.

### 2. Select tier and craft content

Follow the **work-item-templates-g** User Story templates for tier selection and field structure.

**Tier selection:**

- **Simple** -- single behavioral change, obvious scope, 2--3 AC. Use when the need maps to one feature with no ambiguity.
- **Standard** -- involves context, scope boundaries, or constraints. The default tier when more than a trivial change is needed.
- **Complex** -- spans multiple concerns, 5+ potential AC, or contains unknowns. Recommend splitting into vertical slices before creation. If the user agrees, create multiple Simple/Standard stories instead of one Complex story.

**Craft from the user's input:**

- **Title** -- verb + user-facing outcome + scope. Outcome-oriented, not implementation-oriented. Keep under 80 characters.
- **Description** (`System.Description`) -- problem or opportunity, scope boundaries, constraints, non-goals. Do NOT put acceptance criteria here.
- **Acceptance criteria** (`Microsoft.VSTS.Common.AcceptanceCriteria`) -- in the dedicated ADO field. Format per the **work-item-templates-g** AC format guide:
  - Checklist for independent rules
  - Given/When/Then for state-dependent flows
  - Hybrid (recommended) for Standard tier: Given/When/Then for the core flow, checklist for secondary conditions

  Every criterion must pass the black-box test from **requirements-classification-g**: verifiable without knowing internal architecture.

- **Story points** -- infer from scope if apparent (1--5 range). Omit if the user's input doesn't give enough information to estimate.

### 3. Apply INVEST quality gate

Before presenting the draft, verify the story passes INVEST:

| Letter | Check | Fail action |
|--------|-------|-------------|
| **I**ndependent | No dependency on other stories in the same sprint | Extract dependency into a separate story |
| **N**egotiable | States the need, not the solution | Remove implementation prescriptions |
| **V**aluable | Delivers user-visible value | If purely technical, recommend a Task instead |
| **E**stimable | Scope is clear enough to estimate | Add context or recommend a spike |
| **S**mall | Under 5 story points | Split into vertical slices |
| **T**estable | Every AC has a clear pass/fail | Rewrite vague AC |

If the story fails any letter, revise it or recommend an alternative approach (split, retype as Task, spike first) before presenting.

### 4. Create the work item

Follow the **create-work-item-g** shared instructions with:

- **workItemType**: `User Story`
- **title**: the crafted title from step 2
- **typeFields**:

| Field | Value | Condition |
|-------|-------|-----------|
| `Microsoft.VSTS.Common.AcceptanceCriteria` | The crafted AC (markdown) | Always |
| `Microsoft.VSTS.Scheduling.StoryPoints` | The inferred points | When estimable |

- **commonFieldOverrides**:

| Field | Value |
|-------|-------|
| `System.AreaPath` | `FundGuard\Platform\Web\CInfra` |

- **parentSearchType**: `Feature` or `Epic` (not User Story -- stories are the parent type for Tasks/Bugs, but stories themselves link to Features or Epics)

**Note on parent linking:** `create-work-item-g` step 3 normally searches for User Stories as parents. For User Stories, the parent should be a **Feature** or **Epic**. Override the parent search to look for Features/Epics in the target area path. If no Feature/Epic exists, ask the user which one to link or whether to create without a parent hierarchy.

### 5. Triage the work item

If the work item is not assigned to the current user, skip this step -- triaging is the assignee's responsibility.

Otherwise, follow the **triage-transition-g** skill, passing the newly created work item's ID.
