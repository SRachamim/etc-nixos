# Checkout Feature Worktree

Given a feature ID, create a new git worktree with a dedicated branch for the feature.

Follow the **worktree-layout** skill for all path and branch naming conventions.

## Steps

### 1. Resolve the repository root

Run `git worktree list` to identify the **bare root** or **main worktree** path.

### 2. Validate preconditions

- Confirm the branch `feature/<feature id>` does **not** already exist locally (`git branch --list`).
- Confirm the worktree directory does **not** already exist.

If either exists, inform the user and stop — do not overwrite.

### 3. Create the worktree

Create the worktree and branch atomically per the **worktree-layout** skill.

### 4. Confirm success

Run `git worktree list` and show the output so the user can verify the new worktree appears.

Print the full path to the new worktree so the user can open it.
