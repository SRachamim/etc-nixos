---

## name: work-item-triage

description: Mechanical estimate-and-transition of an Azure DevOps work item to the Triaged state. Called programmatically by commands that create or triage work items -- not invoked directly by the user. For user-initiated triage, use the triage command instead.

# Work Item Triage

Mechanically estimate and transition an Azure DevOps work item to the **Triaged** state.

This skill is internal plumbing -- called programmatically by commands that create or triage work items (e.g. **create-task**, **create-bug**, **triage**). When the user asks to triage a work item directly, use the **triage** command instead.

## Steps

### 1. Resolve the work item

Use one of the following, in priority order:

1. **Provided by calling command** -- an ID passed programmatically after creation. Fetch the work item to get its title, description, and type.
2. **Explicit argument** -- the user provided a work item ID directly. Fetch it with full details.

Fetch with `expand: "relations"` so predecessor links are visible for step 2.

If neither is available, ask the user and stop.

### 2. Check for predecessor

Inspect the fetched relations for a **predecessor** link. If one exists, the work item is blocked and cannot be triaged yet:

1. Inform the user that the item has a predecessor dependency.
2. Delegate to the **block-work-item** command, passing the current work item as the blocked ID and the predecessor as the blocker ID.
3. **Stop** -- do not proceed with estimation or state transition.

### 3. Estimate

If `OriginalEstimate`, `RemainingWork`, or `EstimationConfidenceLevel` are already set on the work item, **skip this step** -- carry the existing values forward and do not overwrite them.

Otherwise, follow the **estimation** skill, passing the work item details as input.

Present the estimate summary (T-shirt size, story points, key risks) to the user for confirmation before writing to ADO.

### 4. Update the work item

Call `wit_update_work_item` with:

- **id**: the work item ID
- **updates**:

```json
[
  { "op": "add", "path": "/fields/System.State", "value": "Triaged" },
  { "op": "add", "path": "/fields/Microsoft.VSTS.Common.Priority", "value": "4" },
  { "op": "add", "path": "/fields/Custom.BusinessPriority", "value": "4: Technical" },
  { "op": "add", "path": "/fields/Custom.Version", "value": "<current version>" },
  { "op": "add", "path": "/fields/Microsoft.VSTS.Scheduling.OriginalEstimate", "value": "<hours>" },
  { "op": "add", "path": "/fields/Microsoft.VSTS.Scheduling.RemainingWork", "value": "<hours>" },
  { "op": "add", "path": "/fields/Custom.EstimationConfidenceLevel", "value": "<confidence>" }
]
```

#### Required fields

- `Microsoft.VSTS.Common.Priority` -- ADO requires this when transitioning to Triaged. Default to `4` (lowest) unless the work item warrants higher priority.
- `Custom.BusinessPriority` -- also required for the Triaged transition. Default to `"4: Technical"` for internal/tooling tasks. Other values follow the pattern `"1: Must Have"`, `"2: Should Have"`, `"3: Nice to Have"`, `"4: Technical"`.
- `Custom.Version` -- the current release version (e.g. `26.2.1`). Infer from a recent work item in the same iteration if not known.

#### Estimation fields

Only include the estimation operations (`OriginalEstimate`, `RemainingWork`, `EstimationConfidenceLevel`) when estimation was performed in step 3. If the fields were already set on the work item, omit them from the update.

When included, the **estimation** skill produces hours and a confidence level, not story points. Set `OriginalEstimate` and `RemainingWork` to the same hour value, and `EstimationConfidenceLevel` to the skill's output.

### 5. Confirm

Print the work item **ID**, new **state**, **estimate (hours)**, and **confidence level**.