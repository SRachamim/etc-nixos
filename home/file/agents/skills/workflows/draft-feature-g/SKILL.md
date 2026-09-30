---
name: draft-feature-g
description: Opens a draft pull request linked to the feature work item, for the author's own review before submitting. Leaves the work item state unchanged and sends no Slack messages. Use when the user wants a draft PR for a feature ID or a feature/<id> branch. When NOT to use -- to request review from the team, use submit-feature-g, which also publishes this draft.
disable-model-invocation: true
---

# Draft Feature

Given a feature ID (or inferred from the current branch name), open a draft pull request linked to the work item. The draft is for the author: CI runs and the diff is visible in Azure DevOps before anyone is asked to review.

This skill does not transition the work item, post to Slack, or send DMs. When the draft is ready, `/submit-feature-g` publishes it with auto-complete set, transitions the work item and notifies the team.

## Steps

### 1. Resolve the feature ID

Determine the feature ID using one of the following, in priority order:

1. **Explicit argument** -- the user provided a feature ID directly.
2. **Branch name** -- parse the current branch (`git branch --show-current`). If it matches the pattern `feature/<id>`, extract `<id>`.

If neither yields a feature ID, tell the user the draft will have no work item link and continue.

### 2. Commit uncommitted changes

Run `git status --porcelain` to check for uncommitted changes (staged or unstaged).

- **If changes exist**: follow the **commit-and-push-g** skill in **commit** mode, so the draft includes all work.
- **If no changes exist**: skip this step silently.

### 3. Create the draft pull request

Follow the **create-pr-g** skill, passing:

- **workItemId**: the feature ID resolved in step 1, if any.
- **draft**: true.

The work item is linked to the PR when it is created.

### 4. Confirm completion

Print:

- PR link, marked as a draft
- Work item link, with its state unchanged
- The next step: `/submit-feature-g` when the draft is ready for review

### 5. Evolve

Follow the **capture-improvement-g** skill.
