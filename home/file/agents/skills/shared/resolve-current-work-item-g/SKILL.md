---
name: resolve-current-work-item-g
description: Resolves the current work item ID from explicit input, branch name, or ADO pull request association. Called by **close-worktree-g**, **defer-fix-g**, and **plan-g** skills — not invoked directly by the user.
disable-model-invocation: true
---

# Resolve Current Work Item

Determines the work item ID (and optionally the branch prefix) from available context. This file is a shared skill referenced by **close-worktree-g**, **defer-fix-g**, and **plan-g**.

## Inputs (provided by the calling skill)

| Input | Description |
| --- | --- |
| **explicitId** | *(optional)* A work item ID the user provided directly. |

## Output

| Field | Description |
| --- | --- |
| **workItemId** | The resolved numeric work item ID. |
| **prefix** | *(optional)* `feature` or `hotfix` -- available when resolved from the branch name. |

## Steps

### 1. Explicit argument

If the calling skill provides **explicitId**, use it. Determine the prefix by checking which local branch exists: try `feature/<id>-*` then `hotfix/<id>-*` (also check the legacy format `feature/<id>` and `hotfix/<id>`). If neither exists, the prefix is unknown (acceptable -- some callers don't need it).

Return immediately with the resolved ID and prefix.

### 2. Branch name

Run `git branch --show-current` to get the current branch. If it matches the pattern `^(feature|hotfix)/(\d+)(-.*)?$` (per the **worktree-layout-g** skill), extract the numeric `<id>` from group 2 and the `<prefix>` from group 1. This handles both the current format (`feature/<id>-<slug>`) and the legacy format (`feature/<id>`).

Return immediately with the resolved ID and prefix.

### 3. ADO pull request association

If the branch name did not match the worktree-layout pattern, fall back to Azure DevOps:

1. Identify the repository -- match `git remote get-url origin` against the Azure DevOps project's repositories.
2. List pull requests with the current branch as the source branch (status `Active` or `Completed`).
3. If a PR is found, extract the first linked work item ID from the PR's work item refs.

If a work item ID is found, return it. The prefix is unknown in this case.

If the agent lacks Azure DevOps MCP access, skip this step gracefully and proceed to step 4.

### 4. Failure

If none of the above steps yielded a work item ID, inform the user that the work item could not be determined from context and ask them to provide it explicitly. Stop and wait for input.
