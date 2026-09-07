---
name: create-task-g
description: Creates a Task work item in Azure DevOps from a free-form description, with title, description, and triage on the current iteration. Use when the user wants to capture new work as a tracked Task assigned to themselves.
disable-model-invocation: true
---

# Create Task

Create a new **Task** work item in Azure DevOps, assigned to the current user on the next iteration.

## Steps

### 1. Understand the intent

The user provides a free-form description of what they need to do. If the description is too vague to produce a meaningful title (e.g. just a single ambiguous word), ask a clarifying question. Otherwise, proceed -- do not ask the user to fill in structured fields.

### 2. Select tier and craft content

Follow the **work-item-templates-g** Task templates for tier selection and field structure.

**Tier selection** (based on observable signals from the user's input):

- **Simple** -- under 4 hours, single layer (one file or module), 1--2 done criteria. The cause and approach are obvious from the title alone.
- **Standard** -- 4--8 hours, touches 2--3 files or crosses one module boundary. The default tier.
- **Complex** -- over 8 hours, spans multiple architectural layers, or contains significant unknowns. Recommend decomposition into subtasks before creation. If the user agrees, create multiple Simple/Standard tasks instead.

From the user's input, produce:

- **Title** -- a concise, action-oriented summary. Start with a verb (e.g. "Add ...", "Implement ...", "Update ...", "Investigate ..."). Follow the pattern `<Verb> <what to deliver> <context/parent scope>`. Keep it under 80 characters.
- **Description** (`System.Description`) -- structured per the tier template:
  - **Simple tier**: what needs to happen + done criteria.
  - **Standard tier**: Goal, Context, Approach, Scope, Done criteria.
  - **Complex tier**: recommend decomposition -- do not create a single oversized task.

  Omit sections the user's input doesn't cover -- don't invent details. All task information lives exclusively in `System.Description` -- don't duplicate it into other fields.

- **Original estimate** (`Microsoft.VSTS.Scheduling.OriginalEstimate`) -- infer hours from the scope when apparent. Omit if not estimable from the user's input.
- **Activity** (`Microsoft.VSTS.Common.Activity`) -- infer from context: Development, Testing, Design, or Documentation. Default to Development.

### 3. Create the work item

Follow the **create-work-item-g** shared instructions with:

- **workItemType**: `Task`
- **title**: the crafted title from step 2
- **typeFields**:

| Field | Value | Condition |
|-------|-------|-----------|
| `System.Description` | The crafted description (markdown) | Always |
| `Microsoft.VSTS.Scheduling.OriginalEstimate` | Hours estimate | When estimable from input |
| `Microsoft.VSTS.Common.Activity` | Development / Testing / Design / Documentation | Always (default Development) |

- **commonFieldOverrides**:

| Field | Value |
|-------|-------|
| `System.AreaPath` | `FundGuard\Platform\Web\CInfra` |

### 4. Triage the work item

If the work item is not assigned to the current user, skip this step — triaging is the assignee's responsibility.

Otherwise, follow the **triage-transition-g** skill, passing the newly created work item's ID.
