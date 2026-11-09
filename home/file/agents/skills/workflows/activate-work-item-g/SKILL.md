---
name: activate-work-item-g
description: Transitions an Azure DevOps work item to the Active state, triaging it first when it is still New. Use when starting work on a work item, given an explicit ID or one inferred from the current feature branch.
disable-model-invocation: true
---

# Activate Work Item

Transition an Azure DevOps work item to the **Active** state.

## Input

The user provides a single work item ID, either explicitly or inferred from context (e.g. the current feature branch). If no ID is available, ask.

## Steps

### 1. Resolve the work item

Fetch the work item using `get_work_item` to retrieve its title, type, and current state.

If the ID does not exist, inform the user and stop.

### 2. Validate

If the work item is already in the **Active** state, inform the user and stop.

### 3. Triage a New item

If the work item is in the **New** state, follow the **triage-work-item-g** skill, passing the work item ID. ADO rejects New → Active without the Triaged fields (Original Estimate and the others), and triage fills them from a codebase investigation rather than a guess.

- Continue to step 4 only once triage has applied its updates and the item is **Triaged**.
- If the user rejects the triage draft, or triage stops early (a predecessor blocks the item, or it closes the item as already done), stop without activating.

Triage needs the user's approval. In a non-interactive run (a headless agent CLI invocation, with nobody to approve), skip triage and activation, and report that the item is New and needs triage before it can be activated.

### 4. Transition to Active

Call `update_work_item` with:

- **workItemId**: the work item's ID
- **state**: `"Active"`

### 5. Confirm

Print:

- Work item: **ID**, **title**, new **state**.
- A direct link to the work item in Azure DevOps.

### 6. Evolve

Follow the **capture-improvement-g** skill.
