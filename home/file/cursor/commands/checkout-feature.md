# Checkout Feature Worktree

Given a feature ID, create a new git worktree with a dedicated branch for the feature.

## Steps

### 1. Resolve the repository root

Run `git worktree list` to identify the **bare root** or **main worktree** path. This is the `<root-repo>` used for all path calculations.

### 2. Validate preconditions

- Confirm the branch `feature/<feature id>` does **not** already exist locally (`git branch --list`).
- Confirm the directory `<root-repo>/feature/<feature id>` does **not** already exist.

If either exists, inform the user and stop — do not overwrite.

### 3. Create the worktree

```sh
git worktree add -b "feature/<feature id>" "<root-repo>/feature/<feature id>"
```

This atomically creates:
- A new branch `feature/<feature id>` based on the current HEAD.
- A new worktree checked out at `<root-repo>/feature/<feature id>`.

### 4. Confirm success

Run `git worktree list` and show the output so the user can verify the new worktree appears.

Print the full path to the new worktree so the user can open it.
