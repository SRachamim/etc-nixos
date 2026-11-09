---
name: close-worktree-g
description: Verifies a merged PR and resolved work item, unblocks dependents, and removes the git worktree, its workmux tmux window, and its branches. Use after a feature or hotfix PR is merged and the worktree should be torn down.
disable-model-invocation: true
---

# Close Worktree

Given a work item ID (or inferred from the current branch name), verify the PR is merged, confirm the work item transitioned, and clean up the worktree and branch.

## Steps

### 1. Resolve the work item ID and prefix

Follow the **resolve-current-work-item-g** skill to determine the work item ID and prefix, passing any explicit ID the user provided.

Carry the detected `<prefix>` forward into all subsequent steps.

### 2. Identify the repository

List Azure DevOps projects and locate the repository that matches the current git remote (`git remote get-url origin`).

### 3. Verify the PR is merged

- List pull requests with source branch `refs/heads/<prefix>/<id>`.
- Confirm at least one PR has status **Completed**. If the PR is still active or abandoned, inform the user and stop.

### 4. Verify the work item state

- Fetch the work item linked to the PR.
- PR completion normally auto-transitions linked work items to **Resolved**. Verify this happened.
- Before transitioning, read the work item's comments for conditions on resolving it (e.g. "don't resolve before X"). If one exists, ask the user whether it is met; if it is not, leave the state unchanged and report why in step 8.
- If the work item is still in **Code Review** or another pre-resolved state, transition it to **Resolved**.
- Some work item types (notably **Escaped Defect**) require many mandatory fields for the Resolved state (Tech Domain, Is Regression, Custom Resolved Reason, Root Cause Description, Fix Description, Component, Reason for Defect Escape, Context for Chosen Reason, Task Number for Test Coverage, Blocker Reason). When transitioning these types:
  1. Fetch a recently resolved work item of the same type and area path to discover the allowed field values.
  2. Derive field values from the PR description (root cause, fix description) and the area path (tech domain, component).
  3. If any required field's value cannot be determined, ask the user.

### 5. Unblock dependent work items

- Fetch the work item with `expand: "relations"` to retrieve its relation links.
- Identify all **successor** relations (relation type `System.LinkTypes.Dependency-Forward`). Extract the work item ID from each relation URL.
- Resolve the current user's identity from the ADO API (e.g. via `get_user_team_context` or from the PR creator identity fetched in earlier steps); compare by unique identity ID, not display name.
- For each successor work item:
  1. Fetch it with `expand: "relations"`.
  2. If its state is not **Blocked**, skip it.
  3. Collect all of its **predecessor** relations (`System.LinkTypes.Dependency-Reverse`). For each predecessor, fetch the work item and check its state.
  4. If every predecessor other than the current work item is already in a terminal state (**Resolved**, **Closed**, or **Done**), the current work item was the last remaining blocker. Branch on ownership:
     - **Assigned to current user**: transition the successor from **Blocked** to **Triaged**. Present the transition to the user for approval before applying it. Include the successor work item ID, title, and the list of predecessors that were checked.
     - **NOT assigned to current user**: do not transition the state. Draft a Slack DM to the assignee notifying them their ticket is unblocked. Follow **delivered-text-g** (text type: "Slack message") using **communication-templates-g** section 9 "Significant" tier. Resolve the assignee's Slack identity via `users_search` with their ADO display name or email. Present the message for user approval before sending (per **external-communications-g**). Include the work item link and the completed PR link so the recipient has full context.

### 6. Stash local changes

Follow the **worktree-layout-g** skill to resolve the worktree path.

Run `git -C "<root-repo>/<prefix>/<id>-<slug>" status --porcelain`. If anything is uncommitted or untracked, stash it so it survives the removal (stashes live in the shared repository), then confirm the worktree is clean:

```sh
git -C "<root-repo>/<prefix>/<id>-<slug>" stash push -u -m "<id> <what the changes are>"
```

Report the stash name in step 8.

### 7. Delete the remote branch

```sh
git push origin --delete "<prefix>/<id>-<slug>"
```

If the remote branch was already deleted (e.g., by a server-side policy), ignore the error.

### 8. Confirm completion

Print a summary of what was cleaned up:

- PR link and status
- Work item link and new state
- Dependent work items that were unblocked (if any)
- Remote branch deletion
- Stash name, if local changes were stashed
- That step 11 removes the worktree, its workmux window, and the local branch -- and ends this session if it runs in that window

### 9. Notify the team

Consider whether the completed feature warrants a notification to `#full-stack`. Review the PR description, work item details, and the diff against the base branch to assess whether any changes fall into these categories (non-exhaustive):

- **Infrastructure** -- changes that affect how the system is built, deployed, or operated.
- **Productivity** -- changes that improve other developers' productivity (e.g. new shared utilities, CI improvements, dependency upgrades).
- **Developer experience** -- changes that improve DX (e.g. better error messages, new dev tooling, simplified workflows).

If nothing is notable, state that briefly and move on.

If a notification is warranted, follow the **delivered-text-g** skill (text type: "Slack message"), then compose a message for `#full-stack`.

### 10. Evolve

Follow the **capture-improvement-g** skill.

### 11. Remove the worktree and its window

Run this as the last step, in one command from the main worktree. `workmux remove` deletes the worktree, its tmux window, and the local branch; when this agent runs in that window, the window closes with it, so nothing may follow.

```sh
cd "<root-repo>" && workmux remove -f "<prefix>/<id>-<slug>"; git worktree prune; rmdir "<root-repo>/<prefix>" 2>/dev/null
```

`-f` skips the unmerged-branch confirmation, which is safe because step 3 confirmed the PR is **Completed** and step 6 left the worktree clean. If the worktree has no workmux window, `workmux remove` still removes the worktree and branch. `rmdir` only removes the `<prefix>/` directory when it is empty.
