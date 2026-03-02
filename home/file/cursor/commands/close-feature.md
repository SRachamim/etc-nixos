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

### 5. Unblock dependent work items

- Fetch the work item with `expand: "relations"` to retrieve its relation links.
- Identify all **successor** relations (relation type `System.LinkTypes.Dependency-Forward`). Extract the work item ID from each relation URL.
- For each successor work item:
  1. Fetch it with `expand: "relations"`.
  2. If its state is not **Blocked**, skip it.
  3. Collect all of its **predecessor** relations (`System.LinkTypes.Dependency-Reverse`). For each predecessor, fetch the work item and check its state.
  4. If every predecessor other than the current work item is already in a terminal state (**Resolved**, **Closed**, or **Done**), the current work item was the last remaining blocker. Transition the successor from **Blocked** to **Triaged**.
- Present each transition to the user for approval before applying it. Include the successor work item ID, title, and the list of predecessors that were checked.

### 6. Remove the worktree

Follow the **worktree-layout** skill to resolve the worktree path.

```sh
git worktree remove "<root-repo>/feature/<id>"
```

If the current working directory is inside the worktree being removed, switch to the main worktree first.

### 7. Delete the local and remote branches

```sh
git branch -d "feature/<id>"
git push origin --delete "feature/<id>"
```

Use `-d` (not `-D`) so git refuses if the branch has unmerged changes. If the remote branch was already deleted (e.g., by a server-side policy), ignore the push error.

### 8. Prune worktrees and empty directories

```sh
git worktree prune
rmdir "<root-repo>/feature" 2>/dev/null
```

Clean up stale worktree references that may linger from previous removals. Remove the `feature/` parent directory if it is now empty; `rmdir` is safe because it only succeeds on empty directories.

### 9. Confirm completion

Print a summary of what was cleaned up:

- PR link and status
- Work item link and new state
- Dependent work items that were unblocked (if any)
- Worktree and branch removal confirmation

### 10. Evolve

Follow the **continuous-improvement** skill.
