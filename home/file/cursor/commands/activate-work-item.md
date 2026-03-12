# Activate Work Item

Transition an Azure DevOps work item to the **Active** state.

## Input

The user provides a single work item ID, either explicitly or inferred from context (e.g. the current feature branch). If no ID is available, ask.

## Steps

### 1. Resolve the work item

Fetch the work item using `wit_get_work_item` to retrieve its title, type, and current state.

If the ID does not exist, inform the user and stop.

### 2. Validate

If the work item is already in the **Active** state, inform the user and stop.

### 3. Transition to Active

Call `wit_update_work_item` with:

- **id**: the work item's ID
- **updates**:

```json
[
  { "op": "add", "path": "/fields/System.State", "value": "Active" }
]
```

### 4. Confirm

Print:

- Work item: **ID**, **title**, new **state**.
- A direct link to the work item in Azure DevOps.

### 5. Evolve

Follow the **continuous-improvement** skill.
