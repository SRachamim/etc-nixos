---
name: prune-merged-g
description: Removes local worktrees and branches that have already been merged into the default branch. Use when cleaning up merged feature branches and their associated worktrees.
disable-model-invocation: true
---

# Prune Merged

Remove all local worktrees and branches that have already been merged into the default branch.

Follow the **worktree-layout-g** skill for all path and naming conventions.

## Steps

### 1. Resolve the repository root and default branch

- Run `git worktree list` to identify the **main worktree** path (`<root-repo>`).
- Determine the default branch from the remote: `git symbolic-ref refs/remotes/origin/HEAD`.
- Fetch latest remote state with `git fetch --prune` so merge status is accurate.

### 2. List merged branches

Collect all local `feature/*` branches (per the worktree-layout skill naming convention). Exclude the default branch itself.

For each feature branch:

1. **Fast-forward to remote** -- if the branch has a remote tracking branch, fast-forward it so the local ref is up-to-date: `git fetch origin feature/<id>:feature/<id>` (this is safe for branches not currently checked out; for checked-out worktrees use `git -C <worktree> merge --ff-only`).
2. **Compare by patch content** -- use `git cherry <default-branch> feature/<id>` to check whether the branch's patches are already applied to the default branch. A branch is considered merged if `git cherry` produces no output or only lines starting with `-` (already upstream). If any line starts with `+`, the branch has unapplied patches and should be kept.

### 3. Identify associated worktrees

For each merged branch, check whether a corresponding worktree exists at `<root-repo>/feature/<id>` (via `git worktree list`).

### 4. Detect orphaned worktree directories

List all directories under `<root-repo>/feature/`. For each directory, check whether:
- A matching local branch (`feature/<dirname>`) exists, OR
- A registered worktree points to that path (via `git worktree list`).

Directories with neither are **orphaned**. Include them in the summary table (step 7) with status `orphaned directory`.

### 5. Detect unrecognized local branches

List all local branches and exclude the expected set:
- The default branch
- `latest-stable`, `main`, `master`
- `release/*` and `feature/*` branches

Any remaining branches are **unrecognized** -- likely leftover from ad-hoc PR checkouts or experiments. Include them in the summary table (step 7) with status `stale (unrecognized)` and their last commit subject + age as description.

### 6. Gather branch descriptions

For each merged branch, resolve a short description using the first source that yields a meaningful result:

1. **Work item title** -- if the `<id>` is numeric and Azure DevOps MCP tools are available, fetch the work item title.
2. **Last commit subject** -- `git log -1 --format="%s" feature/<id>`. Skip if the subject is unhelpful (e.g., "wip", "fix", a single word with no context).
3. **Diff-stat summary** -- `git diff --stat $(git merge-base <default-branch> feature/<id>) feature/<id>`. Condense the output into a compact area-of-change description (e.g., "4 files in `src/auth/`, `src/api/`").
4. **"(no description)"** -- if no source yields a result (e.g., empty branch with no unique commits).

Truncate descriptions to ~60 characters for table readability.

### 7. Present the plan

Show the user a summary table of what will be removed:

```
| Item              | Description                          | Worktree                    | Status              |
|-------------------|--------------------------------------|-----------------------------|---------------------|
| feature/123       | Add user authentication flow         | <root-repo>/feature/123     | merged              |
| feature/456       | fix: resolve null pointer in parser  | (none)                      | merged              |
| feature/789       | 4 files in src/auth/, src/api/       | <root-repo>/feature/789     | merged              |
| (dir) 116816      | --                                   | <root-repo>/feature/116816  | orphaned directory  |
| pr-125102-merge   | Merge PR 125102 (3 months ago)       | (none)                      | stale (unrecognized)|
```

**Wait for user confirmation before proceeding.** If the user declines, stop.

### 8. Remove worktrees, branches, and orphaned directories

For each confirmed item, follow the worktree-layout skill cleanup order:

1. **Merged branches with worktrees** -- remove the worktree first: `git worktree remove "<root-repo>/feature/<id>"`, then delete the branch: `git branch -d "feature/<id>"`.
2. **Merged branches without worktrees** -- delete the branch: `git branch -d "feature/<id>"`.
3. **Orphaned directories** -- remove directly: `rm -rf "<root-repo>/feature/<dirname>"`.
4. **Unrecognized branches** -- delete the branch: `git branch -d "<branch-name>"`. If `-d` fails because the branch was never merged into the default branch (e.g., squash-merged via PR), fall back to `-D` after confirming with the user.

Use `-d` (not `-D`) so git refuses if the branch has unmerged changes.

If the current working directory is inside a worktree being removed, switch to the main worktree first.

### 9. Prune stale worktree entries

Run `git worktree prune` to clean up any stale tracking entries (e.g., worktrees whose directories were previously deleted outside of git).

### 10. Confirm completion

Print a summary of what was cleaned up:

- Number of worktrees removed
- Number of branches deleted
- Number of orphaned directories removed
- Number of unrecognized branches deleted
- Number of stale worktree entries pruned
- Any items that could not be removed (and why)

### 11. Evolve

Follow the **capture-improvement-g** skill.
