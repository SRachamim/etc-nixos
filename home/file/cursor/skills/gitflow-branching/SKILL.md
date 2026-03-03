---
name: gitflow-branching
description: Gitflow branching model conventions for Git operations. Use whenever the agent creates branches, merges branches, or reasons about branch lifecycle — applying Gitflow defaults where repository-specific guidelines are silent.
---

# Gitflow Branching

Apply the Gitflow branching model as a *default* framework for Git operations. **Repository-specific guidelines always take priority** — other skills, commands, and rules in this repository override Gitflow whenever they specify something different. Use Gitflow to fill gaps those guidelines leave open.

## Long-lived branches

| Branch | Purpose |
|--------|---------|
| `main` (or `master`) | Always reflects production-ready state. Every merge into this branch is a release. |
| `develop` | Integration branch for the next release. Features merge here. |

If the repository does not have a `develop` branch, do not create one automatically — inform the user and ask how to proceed.

## Branch types

| Type | Branches from | Merges back into | Naming convention |
|------|---------------|-------------------|-------------------|
| Feature | `develop` | `develop` | `feature/<name>` |
| Release | `develop` | `main` **and** `develop` | `release/<version>` |
| Hotfix | `main` | `main` **and** `develop` | `hotfix/<name>` |

## Merge strategy

- Use `--no-ff` for merges into `main` and `develop` to preserve branch history as explicit merge commits.
- Delete the source branch after a successful merge (unless repo policy handles this automatically).

## Release flow

1. Branch `release/<version>` from `develop` when the release scope is complete.
2. Only bug fixes, documentation, and release metadata go into the release branch — no new features.
3. When ready, merge into `main` and tag with the version number.
4. Merge back into `develop` to carry forward any fixes made during release stabilisation.

## Hotfix flow

1. Branch `hotfix/<name>` from `main`.
2. Fix the issue, bump the version if applicable.
3. Merge into `main` and tag.
4. Merge into `develop` (or into the current `release/*` branch if one exists).

## Deference to repository guidelines

This skill yields to repository-specific conventions. Common overrides in this repository:

- The **worktree-layout** skill dictates worktree paths and branch creation commands — follow it for physical layout even when its starting-point branch differs from Gitflow's default.
- The **commit-conventions** skill governs commit structure — follow it regardless of Gitflow's implied practices.
- Commands like **checkout-feature** and **close-feature** encode specific branch lifecycle steps — follow those commands as written.
