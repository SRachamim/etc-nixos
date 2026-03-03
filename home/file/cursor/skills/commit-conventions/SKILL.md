---
name: commit-conventions
description: Commit hygiene and structuring guidelines. Use whenever the agent creates git commits.
---

# Commit Conventions

## Structure

- **Each commit is independently valid** -- the codebase compiles and passes tests after each one.
- **Each commit is focused** -- one logical change per commit.
- **The sequence tells a story** -- a reviewer reading the commits in order can follow the reasoning.
- **Prefer fewer commits** -- don't split artificially. One commit is valid if the change is cohesive.

## Ordering

- **Refactors go in a separate, preceding commit** -- if the change requires restructuring existing code, commit the refactoring on its own before committing the new fix or feature. This lets reviewers (and Git history readers) evaluate each change without the noise of the other.
- **Tests belong with the code they test** -- unless there's a good reason to separate (e.g., adding test infrastructure first).

## Hygiene

- **No empty or trivial commits** -- every commit should deliver meaningful progress.
- **Working tree must be clean when done** -- run `git status` to confirm there are no uncommitted changes.
- If validation steps (linters, formatters, tests) produced auto-fixed modifications, amend the commit that introduced those files or create a fixup commit targeting the appropriate earlier commit.
- If any other staged or unstaged modifications remain, commit them following the established commit structure.
