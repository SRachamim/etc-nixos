# Prune Merged Branches

Remove all local worktrees and branches that have already been merged into the default branch.

Follow the **worktree-layout** skill for all path and naming conventions.

## Steps

### 1. Resolve the repository root and default branch

- Run `git worktree list` to identify the **main worktree** path (`<root-repo>`).
- Determine the default branch from the remote: `git symbolic-ref refs/remotes/origin/HEAD`.
- Fetch latest remote state with `git fetch --prune` so merge status is accurate.

### 2. List merged branches

Run `git branch --merged <default-branch>` to get all local branches fully merged into the default branch.

Filter to only `feature/*` branches (per the worktree-layout skill naming convention).

Exclude the default branch itself and any currently checked-out branch.

### 3. Identify associated worktrees

For each merged branch, check whether a corresponding worktree exists at `<root-repo>/feature/<id>` (via `git worktree list`).

### 4. Present the plan

Show the user a summary table of what will be removed:

```
| Branch | Worktree | Status |
|--------|----------|--------|
| feature/123 | <root-repo>/feature/123 | merged |
| feature/456 | (none) | merged |
```

**Wait for user confirmation before proceeding.** If the user declines, stop.

### 5. Remove worktrees and branches

For each confirmed branch, follow the worktree-layout skill cleanup order:

1. If a worktree exists, remove it first: `git worktree remove "<root-repo>/feature/<id>"`.
2. Then delete the branch: `git branch -d "feature/<id>"`.

Use `-d` (not `-D`) so git refuses if the branch has unmerged changes.

If the current working directory is inside a worktree being removed, switch to the main worktree first.

### 6. Prune stale worktree entries

Run `git worktree prune` to clean up any stale tracking entries (e.g., worktrees whose directories were previously deleted outside of git).

### 7. Confirm completion

Print a summary of what was cleaned up:

- Number of worktrees removed
- Number of branches deleted
- Number of stale worktree entries pruned
- Any branches that could not be deleted (and why)
