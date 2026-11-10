---
name: triage-transition-g
description: Mechanical estimate-and-transition of an Azure DevOps work item to the Triaged state. Called programmatically by skills that create or triage work items -- not invoked directly by the user. For user-initiated triage, use the **triage-work-item-g** skill instead.
disable-model-invocation: true
---

# Triage Transition

Mechanically estimate and transition an Azure DevOps work item to the **Triaged** state.

This skill is internal plumbing -- called programmatically by skills that create or triage work items (e.g. **create-task-g**, **create-bug-g**, **triage-work-item-g**). When the user asks to triage a work item directly, use the **triage-work-item-g** skill instead.

## Steps

### 1. Resolve the work item

Use one of the following, in priority order:

1. **Provided by calling skill** -- an ID passed programmatically after creation. Fetch the work item to get its title, description, and type.
2. **Explicit argument** -- the user provided a work item ID directly. Fetch it with full details.

Fetch with `expand: "relations"` so predecessor links are visible for step 2.

If neither is available, ask the user and stop.

### 2. Check for predecessor

Inspect the fetched relations for a **predecessor** link. If one exists, the work item is blocked and cannot be triaged yet:

1. Inform the user that the item has a predecessor dependency.
2. Delegate to the **block-work-item-g** skill, passing the current work item as the blocked ID and the predecessor as the blocker ID.
3. **Stop** -- do not proceed with estimation or state transition.

### 3. Estimate

If `OriginalEstimate` is already set, **skip this step** -- carry `OriginalEstimate`, `RemainingWork` and `EstimationConfidenceLevel` forward and do not overwrite them, except that an empty `RemainingWork` is set to the `OriginalEstimate` value. A confidence level set without an estimate is a creation default, so estimate it again.

Otherwise, follow the **effort-estimation-g** skill, passing the work item details as input.

Present the estimate summary (T-shirt size, story points, key risks) to the user for confirmation before writing to ADO.

### 4. Update the work item

Call `update_work_item` with:

- **workItemId**: the work item ID
- **state**: `"Triaged"`
- **priority**: `4`
- **additionalFields**:

```json
[
  { "name": "Custom.BusinessPriority", "value": "4: Technical" },
  { "name": "Custom.Version", "value": "<current version>" },
  { "name": "Microsoft.VSTS.Scheduling.OriginalEstimate", "value": "<hours>" },
  { "name": "Microsoft.VSTS.Scheduling.RemainingWork", "value": "<hours>" },
  { "name": "Custom.EstimationConfidenceLevel", "value": "<confidence>" }
]
```

#### Required fields

- **priority** -- ADO requires this when transitioning to Triaged. Default to `4` (lowest) unless the work item warrants higher priority.
- `Custom.BusinessPriority` -- also required for the Triaged transition. Default to `"4: Technical"` for internal/tooling tasks. Other values follow the pattern `"1: Must Have"`, `"2: Should Have"`, `"3: Nice to Have"`, `"4: Technical"`.
- `Custom.Version` -- the current release version. Read the picklist with `get_field_allowed_values` (the item's type, field `Custom.Version`) and pick the release that matches the iteration's quarter (e.g. `11-A-26` -> `26.4`). Never copy it from another work item, because they can carry `Backlog` or retired values.

#### Estimation fields

Only include the estimation fields (`OriginalEstimate`, `RemainingWork`, `EstimationConfidenceLevel`) in `additionalFields` when estimation was performed in step 3. If `OriginalEstimate` was already set on the work item, omit all three from the update, except `RemainingWork` when it is empty: set it to the existing `OriginalEstimate` so the item doesn't reach the sprint without remaining work.

When included, the **effort-estimation-g** skill produces hours and a confidence level, not story points. Set `OriginalEstimate` and `RemainingWork` to the same hour value, and `EstimationConfidenceLevel` to the skill's output.

### Closing without triage

For an item that is superseded, a duplicate or no longer needed, don't triage it. Add a comment that gives the reason and cites the superseding commit, PR or item, then set `state: "Removed"`. A New item can't move to `Closed` without OriginalEstimate, RemainingWork and the other Triaged fields. Filling them with 0 h would record effort that never happened.

### 5. Confirm

Print the work item **ID**, new **state**, **estimate (hours)**, and **confidence level**.