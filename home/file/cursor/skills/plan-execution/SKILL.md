---
name: plan-execution
description: Execution protocol for plans produced by the /plan command. Governs how TODO items prefixed with [commit] or [action] are built, executed, and verified. Use whenever the agent executes TODO items prefixed with [commit] or [action], or implements a plan containing a table of commit/action typed steps.
---

# Plan Execution

This skill defines the protocol for implementing a plan that contains `[commit]` and `[action]` TODO items. It applies whether the plan was just produced by `/plan` in the current conversation or is being continued from a prior session.

## Building the TODO list

1. Add one TODO item per proposed commit. Prefix the content with `[commit]` followed by the planned commit message -- e.g. `[commit] refactor: extract pricing into dedicated module`. The prefix is a reminder that this item requires a real git commit; it is not just a description of work.
2. Add one TODO item for every non-commit action the plan calls for. Prefix the content with `[action]` followed by a short description -- e.g. `[action] Create follow-up task for TODO comments`.
3. Preserve the ordering from the plan. All items start as `pending`; mark the first as `in_progress`.

## Executing each item

### Commit items

TODO content starts with `[commit]`. Implement only the changes described for that commit -- do not pull in work from later items. Then, **before marking the item completed**:

1. Run the commit's validation step.
2. Stage **only** the relevant files (`git add` with explicit paths).
3. Commit with the planned message, following the **commit-conventions** skill.

A commit item is not complete until `git log -1 --oneline` shows the expected commit.

### Non-commit items

TODO content starts with `[action]`. Execute the described action (run a command, create a work item, post a message, etc.), then mark completed.

### Advancing

After completing any item, mark it `completed` and advance the next item to `in_progress`.

## Constraints

- **Do not batch** -- never apply changes from multiple planned commits in a single real commit.
- **One commit per item** -- a `[commit]` TODO item must not be marked `completed` until its corresponding git commit exists. Run `git log -1 --oneline` after committing to confirm.
- **Execute in order** -- implement items in the sequence presented in the plan.
- If a commit's scope needs to change during implementation (e.g. an unexpected file must be touched), update the TODO item's content to reflect the actual change before committing.

## Completion

Once all items are done, follow the hygiene section of the **commit-conventions** skill. The working tree must be clean before considering the plan complete.
