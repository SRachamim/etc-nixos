# Triage Work Item

Estimate and transition an Azure DevOps work item to the **Triaged** state.

This command can be invoked standalone (given a work item ID) or called from other commands (e.g. **create-task**, **create-bug**) that pass the ID programmatically.

## Steps

### 1. Resolve the work item

Use one of the following, in priority order:

1. **Provided by calling command** -- an ID passed programmatically after creation. Fetch the work item to get its title, description, and type.
2. **Explicit argument** -- the user provided a work item ID directly. Fetch it with full details.

If neither is available, ask the user and stop.

### 2. Estimate

Follow the **estimation** skill, passing the work item details as input.

Present the estimate summary (T-shirt size, story points, key risks) to the user for confirmation before writing to ADO.

### 3. Update the work item

Call `wit_update_work_item` with:

- **id**: the work item ID
- **updates**:

```json
[
  { "op": "add", "path": "/fields/System.State", "value": "Triaged" },
  { "op": "add", "path": "/fields/Microsoft.VSTS.Scheduling.StoryPoints", "value": "<story points>" }
]
```

### 4. Confirm

Print the work item **ID**, new **state**, and assigned **story points**.
