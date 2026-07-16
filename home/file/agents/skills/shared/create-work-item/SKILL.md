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

Use the iteration data returned by `get_user_team_context` (called in step 1). Identify the current iteration (the one whose date range contains today) and pick the iteration whose start date is the earliest date **after** the current iteration's end date.

**Verify:** confirm the selected iteration's start date is strictly after the current iteration's end date. If it overlaps or equals the current iteration, pick the next one.

Use the next iteration's path (e.g. `FundGuard\Sprint 43`) as the iteration for the work item. Do NOT use the current iteration's path.

### 3. Find the parent User Story

Every work item must have a parent User Story -- orphan items are not allowed.

1. Call `search_workitems` with a query that returns active User Stories in the same area path and iteration (next iteration resolved in step 2). Order by changed date descending.
2. If no results, broaden by removing the iteration filter (same area path, state Active or New).
3. If still no results, broaden further to any active User Story under the root area path (`FundGuard`).
4. Present the top candidates (ID, title, state) to the user and ask which one to link as the parent. The user may also provide a different story ID directly.

A parent story must be selected before proceeding. Do not allow the user to skip this step.

Store the selected parent story ID for use after creation.

### 4. Format rich-text fields as markdown

All rich-text work item fields (`System.Description`, `Microsoft.VSTS.TCM.ReproSteps`, etc.) must use **markdown**, not HTML. When passing these fields to `create_work_item`, set `format` to `"Markdown"` on each rich-text field entry -- the API defaults to `"Html"` and won't render markdown correctly without it.

Each piece of information belongs in exactly one field -- the field designated for it by the calling skill. Don't duplicate content across fields (e.g. don't copy repro steps into `System.Description` on a Bug, or put task details outside `System.Description` on a Task).

### 5. Present the work item for approval

Apply the **objective-communication** skill when composing titles and descriptions. Read and apply the **external-communications** skill for the approval presentation.

Before creating, show the user the full work item that will be created: title, type, all fields (common and type-specific), assigned to, iteration, and parent User Story. Confirm the iteration is **not** the current sprint -- it should be the one after it. Ask for confirmation. If the user requests changes, revise and re-present.

### 6. Create the work item

Call `create_work_item` with:

- **project**: `FundGuard`
- **workItemType**: as provided by the calling skill
- **fields**: merge in this order -- common fields, then type-specific fields from the calling skill, then `commonFieldOverrides`. Later values win.

Common field defaults:


| Field                     | Default value                              |
| ------------------------- | ------------------------------------------ |
| `System.Title`            | The crafted title                          |
| `System.AssignedTo`       | The identity resolved in step 1            |
| `System.AreaPath`         | `FundGuard\Platform\Web\CInfra`            |
| `System.IterationPath`    | The next iteration path resolved in step 2 |
| `Custom.BusinessPriority` | The inferred business priority (see below) |


Any of these can be overridden via `commonFieldOverrides`.

#### Business Priority

Default to **4: Technical** -- the user is a Software Architect and most work items are technical bugs and tasks with no direct product-facing effect.

Use a higher priority only when the work item clearly has direct business or product impact:


| Value          | When to use                                                                                          |
| -------------- | ---------------------------------------------------------------------------------------------------- |
| `1: Critical`  | Critical production bugs: data loss, security breach, or complete service outage affecting customers |
| `2: Important` | Major customer-facing feature broken or significant business risk                                    |
| `3: Standard`  | Moderate product-facing impact or user-visible degradation                                           |
| `4: Technical` | **Default.** Internal improvements, technical debt, non-customer-facing bugs, refactoring, tooling   |


### 7. Link to parent User Story

Call `manage_work_item_links` with:

- **project**: `FundGuard`
- **updates**: `[{ "id": <new work item ID>, "linkToId": <parent story ID>, "type": "parent" }]`

If the link fails (e.g. the story already has a conflicting hierarchy), inform the user and ask them to select a different parent story. Retry until the link succeeds.

### 8. Triage the work item

Skip this step when any of the following are true:

- `skipTriage` is true.
- The effective `System.AssignedTo` (after applying `commonFieldOverrides`) differs from the current user resolved in step 1 — triaging is the assignee's responsibility.

Otherwise, follow the **triage-transition** skill, passing the newly created work item's ID.

### 9. Confirm success

Print the created work item's **ID**, **title**, **type**, **state**, **assigned to**, **iteration**, and a direct link to the work item in Azure DevOps.

### 10. Evolve

Follow the **continuous-improvement** skill.
