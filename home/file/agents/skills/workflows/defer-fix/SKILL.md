---
name: defer-fix
description: Records an out-of-scope fix as a blocked ADO work item linked to the current task and adds a TODO comment in code. Use when deferring a fix discovered during current work so it remains traceable without expanding scope.
disable-model-invocation: true
---

# Defer Fix

Record an out-of-scope fix as a blocked work item linked to the current task, and leave a TODO comment in the code so the deferred work is traceable.

## Input

| Input | Description | Required |
|-------|-------------|----------|
| **fix description** | What needs fixing and where in the code | Yes |
| **fix work item ID** | An existing ADO work item for the fix | No |

If no work item ID is provided, a new work item is created.

## Steps

### 1. Resolve the current work item

Follow the **resolve-current-work-item** skill to determine the current work item ID.

### 2. Resolve or create the fix work item

- **Work item ID provided** -- fetch it with `wit_get_work_item` to confirm it exists. Append a note to the description mentioning this fix if the existing description doesn't already cover it.
- **No work item ID provided** -- determine whether the deferred fix is a defect or a planned improvement, then follow the **create-bug** or **create-task** skill accordingly. The work item title and description should capture the fix the user described.

### 3. Block the fix work item on the current task

Follow the **block-work-item** skill with:

- **blocked ID**: the fix work item (successor -- can't proceed until the current task is done)
- **blocker ID**: the current work item (predecessor)

### 4. Add TODO comment

Add a `todo` remark to the nearest relevant declaration (function, type, variable) in the code, containing the work item ID and a brief description of the deferred fix.

Apply the **writing-style** skill (using the "Code comments" register) for tone and formatting. Follow whatever TSDoc / JSDoc conventions the surrounding code already uses -- don't impose a fixed template.

### 5. Confirm

Print:

- Fix work item: **ID**, **title**, **state**.
- Current (blocking) work item: **ID**, **title**.
- A direct link to the fix work item in Azure DevOps.
- The file path and line number where the TODO comment was added.

### 6. Evolve

Follow the **continuous-improvement** skill.
