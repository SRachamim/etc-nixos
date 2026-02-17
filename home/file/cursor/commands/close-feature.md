# Close Feature

Given a feature ID (or inferred from the current branch name), verify the PR is merged, confirm the work item transitioned, and clean up the worktree and branch.

## Steps

### 1. Resolve the feature ID

Determine the feature ID using one of the following, in priority order:

1. **Explicit argument** — the user provided a feature ID directly.
2. **Branch name** — parse the current branch (`git branch --show-current`). If it matches the pattern `feature/<id>`, extract `<id>`.

If neither yields a feature ID, ask the user and stop.

### 2. Identify the repository

List Azure DevOps projects and locate the repository that matches the current git remote (`git remote get-url origin`).

### 3. Verify the PR is merged

- List pull requests with source branch `refs/heads/feature/<id>`.
- Confirm at least one PR has status **Completed**. If the PR is still active or abandoned, inform the user and stop.

### 4. Verify the work item state

- Fetch the work item linked to the PR.
- PR completion normally auto-transitions linked work items to **Resolved**. Verify this happened.
- If the work item is still in **Code Review** or another pre-resolved state, warn the user and offer to transition it manually.

### 5. Remove the worktree

Follow the **worktree-layout** skill to resolve the worktree path.

```sh
git worktree remove "<root-repo>/feature/<id>"
```

If the current working directory is inside the worktree being removed, switch to the main worktree first.

### 6. Delete the local branch

```sh
git branch -d "feature/<id>"
```

Use `-d` (not `-D`) so git refuses if the branch has unmerged changes.

### 7. Confirm completion

Print a summary of what was cleaned up:

- PR link and status
- Work item link and new state
- Worktree and branch removal confirmation
