# Submit Feature for Review

Given a feature ID (or inferred from the current branch name), open a pull request, link it to the work item, transition the work item to review, and notify the team on Slack.

## Steps

### 1. Resolve the feature ID

Determine the feature ID using one of the following, in priority order:

1. **Explicit argument** — the user provided a feature ID directly.
2. **Branch name** — parse the current branch (`git branch --show-current`). If it matches the pattern `feature/<id>`, extract `<id>`.

If neither yields a feature ID, ask the user and stop.

### 2. Identify the repository and default branch

- List Azure DevOps projects and locate the repository that matches the current git remote (`git remote get-url origin`).
- Determine the repository's **default branch** (this is the PR target).

### 3. Gather context for the PR

- Fetch the work item by ID to get its **title**, **description**, and **acceptance criteria**.
- Run `git log --oneline <default-branch>..HEAD` to collect the commits that will be in the PR.
- Run `git diff <default-branch>...HEAD --stat` to summarize changed files.

### 4. Compose the PR description

Draft a PR description with a short summary of the change (derived from the work item and commits).

Follow the **message-formatting** skill for all formatting.

**Present the PR title and description to the user for approval before creating the PR.**

### 5. Create the pull request

- Push the current branch to the remote if it has not been pushed yet (`git push -u origin HEAD`).
- Create the PR targeting the default branch using the approved title and description.
- Link the work item to the PR.

### 6. Transition the work item

Update the work item state to **Code Review**.

### 7. Notify the team on Slack

Compose a message for the **#team-cinfra** Slack channel. The message should include:

- A link to the PR (linked on the PR number, per **message-formatting** skill).
- A link to the work item (linked on the work item ID).
- A one-line summary of what the change does.

**Present the Slack message to the user for approval before posting.**

### 8. Confirm completion

Print a summary of everything that was done:

- PR link
- Work item link and new state
- Slack message confirmation
