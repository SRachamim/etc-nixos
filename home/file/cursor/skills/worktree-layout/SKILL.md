---
name: worktree-layout
description: Conventions for git worktree paths and branch naming. Use whenever the agent creates, navigates, or removes worktrees.
---

# Worktree Layout

## Branch Naming

- Features: `feature/<work-item-id>`

## Worktree Paths

- Resolve the **bare root** or **main worktree** via `git worktree list`. This is the `<root-repo>`.
- Feature worktrees live at: `<root-repo>/feature/<work-item-id>`

## Creation

- Never overwrite an existing worktree or branch. If either exists, inform the user and stop.
- Create atomically with `git worktree add -b "feature/<id>" "<root-repo>/feature/<id>"`.

## Cleanup

- Remove the worktree first: `git worktree remove "<root-repo>/feature/<id>"`.
- Then delete the branch: `git branch -d "feature/<id>"`.
- Use `-d` (not `-D`) so git refuses if the branch has unmerged changes.
- If the current directory is inside the worktree being removed, switch to the main worktree first.
