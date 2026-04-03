---
name: worktree-layout
description: Conventions for git worktree paths and branch naming. Use whenever the agent creates, navigates, or removes worktrees.
---

# Worktree Layout

This skill operates within the broader **gitflow-branching** model. It overrides Gitflow's defaults for physical layout and starting-point branch.

## Branch Naming

- Features: `feature/<work-item-id>`
- Hotfixes: `hotfix/<work-item-id>`

## Choosing the Prefix

| Starting ref matches | Prefix |
|----------------------|--------|
| `release/*` or `origin/release/*` | `hotfix` |
| Anything else | `feature` |

The prefix determines the branch name (`<prefix>/<id>`) and the worktree path (`<root-repo>/<prefix>/<id>`).

## Worktree Paths

- Resolve the **bare root** or **main worktree** via `git worktree list`. This is the `<root-repo>`.
- Feature worktrees live at: `<root-repo>/feature/<work-item-id>`
- Hotfix worktrees live at: `<root-repo>/hotfix/<work-item-id>`

## Creation

- Never overwrite an existing worktree or branch. If either exists, inform the user and stop.
- Determine the **starting ref**:
  - For the `fgrepo` repository, always use `origin/latest-stable`.
  - For all other repositories, determine the default branch (e.g. `main`, `master`) via `git remote show origin` or equivalent and use `origin/<default-branch>`.
- If the user explicitly requests a different starting point, use that instead of the default branch.
- Determine the **prefix** from the starting ref using the table in **Choosing the Prefix** above.
- Fetch the latest state of the starting ref before branching: `git fetch origin <branch>`.
- Create the worktree from the fetched ref: `git worktree add -b "<prefix>/<id>" "<root-repo>/<prefix>/<id>" "<starting-ref>"`.

## Cleanup

- Remove the worktree first: `git worktree remove "<root-repo>/<prefix>/<id>"`.
- Then delete the branch: `git branch -d "<prefix>/<id>"`.
- Use `-d` (not `-D`) so git refuses if the branch has unmerged changes.
- If the current directory is inside the worktree being removed, switch to the main worktree first.
