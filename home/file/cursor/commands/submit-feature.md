# Submit Feature for Review

Given a feature ID (or inferred from the current branch name), open a pull request, link it to the work item, transition the work item to review, and notify the team on Slack.

## Steps

### 1. Resolve the feature ID

Determine the feature ID using one of the following, in priority order:

1. **Explicit argument** — the user provided a feature ID directly.
2. **Branch name** — parse the current branch (`git branch --show-current`). If it matches the pattern `feature/<id>`, extract `<id>`.

If neither yields a feature ID, ask the user and stop.

### 2. Create the pull request

Follow the **create-pull-request** command, passing:

- **workItemId**: the feature ID resolved in step 1.

The shared command will identify the repository, gather context, compose the description, and create the PR. **Do not compose or present the Slack message yet** — the user may want to verify the PR live before notifying the team.

### 3. Transition the work item

Update the work item state to **Code Review**.

When transitioning a Task, Azure DevOps requires `CompletedWork` to be non-empty. Set it to `OriginalEstimate` (or the actual hours spent) and `RemainingWork` to `0`. Read these values from the work item fetched during PR creation.

### 4. Notify the team on Slack

**This step begins only after the PR has been created and the link presented in step 2.** Do not batch this approval with the PR approval — they are separate interactions.

Defaults:

- Slack workspace: `fundguard.slack.com`
- Permalink format: `https://fundguard.slack.com/archives/<channel_id>/p<ts_without_dot>`

When the user asks to share/send a message to a person by name, look up their Slack user ID via `slack_get_users`. Paginate through all pages using the `cursor` parameter until the user is found or all pages are exhausted. Do not stop after the first page.

Compose a message for the **#team-cinfra** Slack channel. The message should include:

- A link to the PR (linked on the PR number, per **external-communications** skill).
- A link to the work item (linked on the work item ID).
- A one-line summary of what the change does.

**Present the Slack message to the user for approval before posting.**

### 5. Confirm completion

Print a summary of everything that was done:

- PR link
- Work item link and new state
- Slack message confirmation

### 6. Evolve

Follow the **continuous-improvement** skill.
