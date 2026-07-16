---
name: create-work-item
description: Common steps for creating a new Azure DevOps work item in the FundGuard project, including iteration assignment, parent linking, and triage. Called by create-task, create-bug, and request-environment-access skills — not invoked directly by the user.
disable-model-invocation: true
---

# Create Work Item -- Shared Instructions

Common steps for creating a new Azure DevOps work item in the **FundGuard** project.

This file is a shared skill. It is referenced by the **create-task**, **create-bug**, and **request-environment-access** skills, which supply the work item type, crafted title, and type-specific fields.

## Inputs (provided by the calling skill)


| Input                    | Description                                                                                                                                                   |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **workItemType**         | The ADO work item type (`Task`, `Bug`, etc.)                                                                                                                  |
| **title**                | A crafted title for the work item                                                                                                                             |
| **typeFields**           | Any type-specific fields (e.g. repro steps for bugs)                                                                                                          |
| **commonFieldOverrides** | *(optional)* Field/value pairs that override the defaults in the common fields table (e.g. `System.AssignedTo`, `System.AreaPath`). Omit to use the defaults. |
| **skipTriage**           | *(optional, default false)* When true, skip the triage step. Use for work items assigned to other teams.                                                      |


## Steps

### 1. Resolve the current user

Use `get_user_team_context` to look up the authenticated user's identity and team context (including iterations). The resolved identity is used for assignment by default and is always available to callers that need the display name (e.g. for titles).

If no identities are found, fall back to `search_workitems` for project `FundGuard`, fetch one of the returned work items, and extract the `System.AssignedTo` value.

If `commonFieldOverrides` supplies `System.AssignedTo`, that value is used for assignment instead of the resolved identity.

### 2. Find the next iteration

**Constraint: NEVER assign work items to the current iteration. Always use the iteration immediately following the current one.**

`get_user_team_context` (called in step 1) returns the **current** iteration per team. It does not return a list of all future iterations.

To find the next iteration:

1. From the `get_user_team_context` response, find the current iteration for the "FundGuard" team (or the team matching the target area path). Note its `finishDate` and iteration name pattern.
2. Iteration names follow the pattern `<month>-<letter>-<year>` (e.g. `7-A-26`, `7-B-26`, `7-C-26`). Each month has three two-week sprints (A, B, C). Compute the next iteration name by advancing the letter (A->B, B->C) or rolling to the next month (C -> next month's A).
3. Construct the next iteration path as `FundGuard\\<next iteration name>` (e.g. `FundGuard\\7-B-26`).
4. If the computed name doesn't match the pattern or you're unsure, fall back to `search_workitems` with a WIQL query: `SELECT [System.Id] FROM WorkItems WHERE [System.IterationPath] UNDER 'FundGuard' AND [System.ChangedDate] > @Today - 30 ORDER BY [System.IterationPath] DESC` to discover recent iteration paths.

Use the next iteration's path for the work item. Do NOT use the current iteration's path.

### 3. Find the parent User Story

Every work item must have a parent User Story -- orphan items are not allowed.

1. Call `search_workitems` with `types: ["User Story"]`, `states: ["Active"]`, `areaPath` matching the target area, and `iterationPath` matching the next iteration resolved in step 2.
2. If no results, broaden by removing the `iterationPath` filter (same area path, states `["Active", "New"]`).
3. If still no results, broaden further with `areaPath: "FundGuard"` and `states: ["Active"]`.
4. Present the top candidates (ID, title, state) to the user and ask which one to link as the parent. The user may also provide a different story ID directly.

A parent story must be selected before proceeding. Do not allow the user to skip this step.

Store the selected parent story ID for use after creation.

### 4. Format rich-text fields as markdown

The `create_work_item` tool defaults to markdown format for rich-text fields. Do not pass `format: "html"` -- the default is correct.

Each piece of information belongs in exactly one field -- the field designated for it by the calling skill. Don't duplicate content across fields (e.g. don't copy repro steps into description on a Bug, or put task details outside description on a Task).

### 5. Present the work item for approval

Apply the **objective-communication** skill when composing titles and descriptions. Read and apply the **external-communications** skill for the approval presentation.

Before creating, show the user the full work item that will be created: title, type, all fields (common and type-specific), assigned to, iteration, and parent User Story. Confirm the iteration is **not** the current sprint -- it should be the one after it. Ask for confirmation. If the user requests changes, revise and re-present.

### 6. Create the work item and link to parent

Call `create_work_item` with:

- **title**: the crafted title
- **type**: as provided by the calling skill (e.g. `"Task"`, `"Bug"`)
- **assignedTo**: the email resolved in step 1 (overridable via `commonFieldOverrides`)
- **areaPath**: `"FundGuard\\Platform\\Web\\CInfra"` (overridable via `commonFieldOverrides`)
- **iterationPath**: the next iteration path resolved in step 2
- **parentId**: the parent User Story ID from step 3
- **description**: from calling skill's type-specific fields
- **reproSteps**: from calling skill's type-specific fields (for Bug type)
- **additionalFields**: `[{ "name": "Custom.BusinessPriority", "value": "<priority>" }]`
- **idempotencyKey**: generate a unique key (e.g. `"create-<type>-<timestamp>"`) to prevent duplicates on retry

Merge fields in this order: common defaults, then type-specific fields from the calling skill, then `commonFieldOverrides`. Later values win.

If creation fails due to a parent hierarchy conflict, inform the user and ask them to select a different parent story. Retry until it succeeds.

#### Business Priority

Default to **4: Technical** -- the user is a Software Architect and most work items are technical bugs and tasks with no direct product-facing effect.

Use a higher priority only when the work item clearly has direct business or product impact:


| Value          | When to use                                                                                          |
| -------------- | ---------------------------------------------------------------------------------------------------- |
| `1: Critical`  | Critical production bugs: data loss, security breach, or complete service outage affecting customers |
| `2: Important` | Major customer-facing feature broken or significant business risk                                    |
| `3: Standard`  | Moderate product-facing impact or user-visible degradation                                           |
| `4: Technical` | **Default.** Internal improvements, technical debt, non-customer-facing bugs, refactoring, tooling   |


### 7. Triage the work item

Skip this step when any of the following are true:

- `skipTriage` is true.
- The effective `System.AssignedTo` (after applying `commonFieldOverrides`) differs from the current user resolved in step 1 — triaging is the assignee's responsibility.

Otherwise, follow the **triage-transition** skill, passing the newly created work item's ID.

### 8. Confirm success

Print the created work item's **ID**, **title**, **type**, **state**, **assigned to**, **iteration**, and a direct link to the work item in Azure DevOps.

### 9. Evolve

Follow the **continuous-improvement** skill.
