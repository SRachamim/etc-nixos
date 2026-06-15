---
name: checkout-worktree
description: Creates a git worktree with a dedicated feature or hotfix branch for a work item ID and activates the work item. Use when starting development on an Azure DevOps work item in an isolated worktree.
disable-model-invocation: true
---

# Checkout Worktree

Given a work item ID and an optional starting ref, create a new git worktree with a dedicated branch. The branch prefix (`feature/` or `hotfix/`) is determined by the starting ref per the **worktree-layout** skill.

Follow the **worktree-layout** skill for all path, branch naming, and prefix conventions. When the user provides a starting ref, pass it through to the **worktree-layout** skill instead of using the repository default.

## Steps

### 1. Resolve the repository root

Run `git worktree list` to identify the **bare root** or **main worktree** path.

### 2. Determine the prefix

Follow the **worktree-layout** skill to choose the prefix based on the starting ref. Use the resulting `<prefix>/<id>` for all subsequent steps.

### 3. Validate preconditions

- Confirm the branch `<prefix>/<id>` does **not** already exist locally (`git branch --list`).
- Confirm the worktree directory does **not** already exist.

If either exists, inform the user and stop -- do not overwrite.

### 4. Create the worktree

Create the worktree and branch atomically per the **worktree-layout** skill.

### 5. Activate the work item

Follow the **activate-work-item** skill, passing the work item ID.

### 6. Confirm success

Run `git worktree list` and show the output so the user can verify the new worktree appears.

Print the full path to the new worktree so the user can open it.

### 7. Evolve

Follow the **continuous-improvement** skill.
