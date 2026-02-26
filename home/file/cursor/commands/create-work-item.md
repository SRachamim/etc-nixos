# Create Work Item — Shared Instructions

Common steps for creating a new Azure DevOps work item in the **FundGuard** project.

This file is not a standalone command. It is referenced by the **create-task** and **create-bug** commands, which supply the work item type, crafted title, and type-specific fields.

## Inputs (provided by the calling command)

| Input | Description |
|-------|-------------|
| **workItemType** | The ADO work item type (`Task`, `Bug`, etc.) |
| **title** | A crafted title for the work item |
| **typeFields** | Any type-specific fields (e.g. repro steps for bugs) |

## Steps

### 1. Resolve the current user

Use `core_get_identity_ids` to look up the authenticated user's identity. Use the returned identity ID for assignment.

### 2. Find the current iteration

Call `work_list_team_iterations` with:

- **project**: `FundGuard`
- **team**: `FundGuard Team`
- **timeframe**: `current`

Use the iteration path from the result (e.g. `FundGuard\Sprint 42`).

If the call fails because the team name is wrong, fall back to `work_list_iterations` for project `FundGuard`, then pick the iteration whose date range contains today's date.

### 3. Present the work item for approval

Before creating, show the user the full work item that will be created: title, type, all fields (common and type-specific), assigned to, and iteration. Ask for confirmation. If the user requests changes, revise and re-present.

### 4. Create the work item

Call `wit_create_work_item` with:

- **project**: `FundGuard`
- **workItemType**: as provided by the calling command
- **fields**: combine the common fields below with the type-specific fields from the calling command

Common fields:

| Field | Value |
|-------|-------|
| `System.Title` | The crafted title |
| `System.AssignedTo` | The identity resolved in step 1 |
| `System.IterationPath` | The current iteration path from step 2 |

### 5. Confirm success

Print the created work item's **ID**, **title**, **type**, **assigned to**, **iteration**, and a direct link to the work item in Azure DevOps.
