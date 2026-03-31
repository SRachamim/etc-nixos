# Close Worktree

Given a work item ID (or inferred from the current branch name), verify the PR is merged, confirm the work item transitioned, and clean up the worktree and branch.

## Steps

### 1. Resolve the work item ID and prefix

Determine the work item ID and branch prefix using one of the following, in priority order:

1. **Explicit argument** -- the user provided a work item ID directly. Determine the prefix by checking which branch exists: try `feature/<id>` then `hotfix/<id>`.
2. **Branch name** -- parse the current branch (`git branch --show-current`). If it matches `feature/<id>` or `hotfix/<id>`, extract the `<prefix>` and `<id>`.

If neither yields a work item ID, ask the user and stop. Carry the detected `<prefix>` forward into all subsequent steps.

### 2. Identify the repository

List Azure DevOps projects and locate the repository that matches the current git remote (`git remote get-url origin`).

### 3. Verify the PR is merged

- List pull requests with source branch `refs/heads/<prefix>/<id>`.
- Confirm at least one PR has status **Completed**. If the PR is still active or abandoned, inform the user and stop.

### 4. Verify the work item state

- Fetch the work item linked to the PR.
- PR completion normally auto-transitions linked work items to **Resolved**. Verify this happened.
- If the work item is still in **Code Review** or another pre-resolved state, transition it to **Resolved**.
- Some work item types (notably **Escaped Defect**) require many mandatory fields for the Resolved state (Tech Domain, Is Regression, Custom Resolved Reason, Root Cause Description, Fix Description, Component, Reason for Defect Escape, Context for Chosen Reason, Task Number for Test Coverage, Blocker Reason). When transitioning these types:
  1. Fetch a recently resolved work item of the same type and area path to discover the allowed field values.
  2. Derive field values from the PR description (root cause, fix description) and the area path (tech domain, component).
  3. If any required field's value cannot be determined, ask the user.

### 5. Unblock dependent work items

- Fetch the work item with `expand: "relations"` to retrieve its relation links.
- Identify all **successor** relations (relation type `System.LinkTypes.Dependency-Forward`). Extract the work item ID from each relation URL.
- For each successor work item:
  1. Fetch it with `expand: "relations"`.
  2. If its state is not **Blocked**, skip it.
  3. Collect all of its **predecessor** relations (`System.LinkTypes.Dependency-Reverse`). For each predecessor, fetch the work item and check its state.
  4. If every predecessor other than the current work item is already in a terminal state (**Resolved**, **Closed**, or **Done**), the current work item was the last remaining blocker. Transition the successor from **Blocked** to **Triaged**.
- Present each transition to the user for approval before applying it. Include the successor work item ID, title, and the list of predecessors that were checked.

### 6. Remove the worktree

Follow the **worktree-layout** skill to resolve the worktree path.

```sh
git worktree remove "<root-repo>/<prefix>/<id>"
```

If the current working directory is inside the worktree being removed, switch to the main worktree first.

### 7. Delete the local and remote branches

```sh
git branch -d "<prefix>/<id>"
git push origin --delete "<prefix>/<id>"
```

Use `-d` so git refuses if the branch has unmerged changes. If `-d` fails because the PR targeted a non-default branch (e.g. a release branch) or used squash merge, and the PR is confirmed **Completed** via the API, fall back to `-D`. If the remote branch was already deleted (e.g., by a server-side policy), ignore the push error.

### 8. Prune worktrees and empty directories

```sh
git worktree prune
rmdir "<root-repo>/<prefix>" 2>/dev/null
```

Clean up stale worktree references that may linger from previous removals. Remove the `<prefix>/` parent directory if it is now empty; `rmdir` is safe because it only succeeds on empty directories.

### 9. Confirm completion

Print a summary of what was cleaned up:

- PR link and status
- Work item link and new state
- Dependent work items that were unblocked (if any)
- Worktree and branch removal confirmation

### 10. Notify the team

Consider whether the completed feature warrants a notification to `#full-stack`. Review the PR description, work item details, and the diff against the base branch to assess whether any changes fall into these categories (non-exhaustive):

- **Infrastructure** -- changes that affect how the system is built, deployed, or operated.
- **Productivity** -- changes that improve other developers' productivity (e.g. new shared utilities, CI improvements, dependency upgrades).
- **Developer experience** -- changes that improve DX (e.g. better error messages, new dev tooling, simplified workflows).

If nothing is notable, state that briefly and move on.

If a notification is warranted, compose a message for `#full-stack` following the **external-communications** skill.

### 11. Evolve

Follow the **continuous-improvement** skill.
