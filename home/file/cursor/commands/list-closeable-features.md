# List Closeable Features

Scan all local `feature/*` branches, check Azure DevOps for completed PRs and resolved work items, and present a summary of features ready to be closed via `/close-feature`.

## Steps

### 1. Identify the repository

- Run `git worktree list` to identify the **main worktree** path (`<root-repo>`).
- List Azure DevOps projects and locate the repository that matches the current git remote (`git remote get-url origin`).
- Determine the default branch from the remote: `git symbolic-ref refs/remotes/origin/HEAD`.

### 2. Collect feature branches

List all local branches matching `feature/*`:

```sh
git branch --list "feature/*" --format="%(refname:short)"
```

If none exist, inform the user and stop.

### 3. Check PR and work item status

For each `feature/<id>` branch, query Azure DevOps:

1. **List PRs** with source branch `refs/heads/feature/<id>` and status `All` to find any associated pull request.
2. **Classify** each branch into one of:
   - **Closeable** — at least one PR has status **Completed**.
   - **Active PR** — a PR exists but is still **Active** (in review).
   - **Abandoned PR** — the PR was abandoned.
   - **No PR** — no pull request was ever created for this branch.

For branches classified as **Closeable**, also fetch the linked work item and record its current state (e.g. Resolved, Code Review, Active).

### 4. Check for associated worktrees

For each feature branch, check whether a corresponding worktree exists at `<root-repo>/feature/<id>` (via `git worktree list`).

### 5. Present the results

Show a summary table grouped by status, closeable features first:

```
Closeable features (PR completed):

| Branch          | PR     | Work Item       | State    | Worktree |
|-----------------|--------|-----------------|----------|----------|
| feature/12345   | #101   | #12345 Resolved | Resolved | yes      |
| feature/12346   | #102   | #12346 Resolved | Resolved | no       |

Other features:

| Branch          | PR     | Status   | Worktree |
|-----------------|--------|----------|----------|
| feature/12400   | #110   | Active   | yes      |
| feature/12401   | (none) | No PR    | yes      |
```

If there are closeable features, suggest running `/close-feature <id>` for each one. If a closeable feature's work item is not in **Resolved** state, flag it with a warning.

### 6. Evolve

Follow the **continuous-improvement** skill.
