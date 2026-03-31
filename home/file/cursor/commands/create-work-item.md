# Create Work Item -- Shared Instructions

Common steps for creating a new Azure DevOps work item in the **FundGuard** project.

This file is not a standalone command. It is referenced by the **create-task**, **create-bug**, and **request-environment-access** commands, which supply the work item type, crafted title, and type-specific fields.

## Inputs (provided by the calling command)

| Input | Description |
|-------|-------------|
| **workItemType** | The ADO work item type (`Task`, `Bug`, etc.) |
| **title** | A crafted title for the work item |
| **typeFields** | Any type-specific fields (e.g. repro steps for bugs) |
| **commonFieldOverrides** | *(optional)* Field/value pairs that override the defaults in the common fields table (e.g. `System.AssignedTo`, `System.AreaPath`). Omit to use the defaults. |
| **skipTriage** | *(optional, default false)* When true, skip the triage step. Use for work items assigned to other teams. |

## Steps

### 1. Resolve the current user

Use `core_get_identity_ids` to look up the authenticated user's identity. The resolved identity is used for assignment by default and is always available to callers that need the display name (e.g. for titles).

If no identities are found, fall back to `wit_my_work_items` for project `FundGuard`, fetch one of the returned work items, and extract the `System.AssignedTo` value.

If `commonFieldOverrides` supplies `System.AssignedTo`, that value is used for assignment instead of the resolved identity.

### 2. Find the current iteration

Call `work_list_team_iterations` with:

- **project**: `FundGuard`
- **team**: `FundGuard Team`
- **timeframe**: `current`

Use the iteration path from the result (e.g. `FundGuard\Sprint 42`).

If the call fails because the team name is wrong, fall back to `work_list_iterations` for project `FundGuard`, then pick the iteration whose date range contains today's date.

### 3. Format rich-text fields as markdown

All rich-text work item fields (`System.Description`, `Microsoft.VSTS.TCM.ReproSteps`, etc.) must use **markdown**, not HTML. Azure DevOps renders markdown natively in these fields -- prefer it for readability in both the web UI and API responses.

### 4. Present the work item for approval

Apply the **writing-style** skill (using the "Work-item descriptions and comments" register) when composing titles and descriptions.

Before creating, show the user the full work item that will be created: title, type, all fields (common and type-specific), assigned to, and iteration. Ask for confirmation. If the user requests changes, revise and re-present.

### 5. Create the work item

Call `wit_create_work_item` with:

- **project**: `FundGuard`
- **workItemType**: as provided by the calling command
- **fields**: merge in this order -- common fields, then type-specific fields from the calling command, then `commonFieldOverrides`. Later values win.

Common field defaults:

| Field | Default value |
|-------|---------------|
| `System.Title` | The crafted title |
| `System.AssignedTo` | The identity resolved in step 1 |
| `System.AreaPath` | `FundGuard\Platform\Web\CInfra` |
| `System.IterationPath` | The current iteration path from step 2 |
| `Custom.BusinessPriority` | The inferred business priority (see below) |

Any of these can be overridden via `commonFieldOverrides`.

#### Business Priority

Default to **4: Technical** -- the user is a Software Architect and most work items are technical bugs and tasks with no direct product-facing effect.

Use a higher priority only when the work item clearly has direct business or product impact:

| Value | When to use |
|-------|-------------|
| `1: Critical` | Critical production bugs: data loss, security breach, or complete service outage affecting customers |
| `2: Important` | Major customer-facing feature broken or significant business risk |
| `3: Standard` | Moderate product-facing impact or user-visible degradation |
| `4: Technical` | **Default.** Internal improvements, technical debt, non-customer-facing bugs, refactoring, tooling |

### 6. Triage the work item

Skip this step when any of the following are true:

- `skipTriage` is true.
- The effective `System.AssignedTo` (after applying `commonFieldOverrides`) differs from the current user resolved in step 1 — triaging is the assignee's responsibility.

Otherwise, follow the **work-item-triage** skill, passing the newly created work item's ID.

### 7. Confirm success

Print the created work item's **ID**, **title**, **type**, **state**, **assigned to**, **iteration**, and a direct link to the work item in Azure DevOps.

### 8. Evolve

Follow the **continuous-improvement** skill.
