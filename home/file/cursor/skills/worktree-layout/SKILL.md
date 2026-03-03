---
name: worktree-layout
description: Conventions for git worktree paths and branch naming. Use whenever the agent creates, navigates, or removes worktrees.
---

# Worktree Layout

This skill operates within the broader **gitflow-branching** model. It overrides Gitflow's defaults for physical layout and starting-point branch.

## Branch Naming

- Features: `feature/<work-item-id>`

## Worktree Paths

- Resolve the **bare root** or **main worktree** via `git worktree list`. This is the `<root-repo>`.
- Feature worktrees live at: `<root-repo>/feature/<work-item-id>`

## Creation

- Never overwrite an existing worktree or branch. If either exists, inform the user and stop.
- Determine the repository's default branch (e.g. `main`, `master`) via `git remote show origin` or equivalent.
- Fetch the latest state of that branch before branching: `git fetch origin <default-branch>`.
- Create the worktree from the fetched ref: `git worktree add -b "feature/<id>" "<root-repo>/feature/<id>" "origin/<default-branch>"`.
- If the user explicitly requests a different starting point, use that instead of the default branch.

## Cleanup

- Remove the worktree first: `git worktree remove "<root-repo>/feature/<id>"`.
- Then delete the branch: `git branch -d "feature/<id>"`.
- Use `-d` (not `-D`) so git refuses if the branch has unmerged changes.
- If the current directory is inside the worktree being removed, switch to the main worktree first.
