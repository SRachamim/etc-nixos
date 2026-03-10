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
  { "op": "add", "path": "/fields/Microsoft.VSTS.Common.Priority", "value": "4" },
  { "op": "add", "path": "/fields/Custom.Version", "value": "<current version>" },
  { "op": "add", "path": "/fields/Microsoft.VSTS.Scheduling.OriginalEstimate", "value": "<hours>" },
  { "op": "add", "path": "/fields/Microsoft.VSTS.Scheduling.RemainingWork", "value": "<hours>" },
  { "op": "add", "path": "/fields/Custom.EstimationConfidenceLevel", "value": "<confidence>" }
]
```

#### Required fields

- `Microsoft.VSTS.Common.Priority` -- ADO requires this when transitioning to Triaged. Default to `4` (lowest) unless the work item warrants higher priority.
- `Custom.Version` -- the current release version (e.g. `26.2.1`). Infer from a recent work item in the same iteration if not known.

#### Estimation fields

The **estimation** skill produces hours and a confidence level, not story points. Set `OriginalEstimate` and `RemainingWork` to the same hour value, and `EstimationConfidenceLevel` to the skill's output.

### 4. Confirm

Print the work item **ID**, new **state**, **estimate (hours)**, and **confidence level**.
