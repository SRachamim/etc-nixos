---
name: submit-feature
description: Opens a pull request, links it to the feature work item, transitions the item to Code Review, and notifies the team on Slack. Use when submitting a feature for review, given a feature ID or a feature/<id> branch name.
disable-model-invocation: true
---

# Submit Feature for Review

Given a feature ID (or inferred from the current branch name), open a pull request, link it to the work item, transition the work item to review, and notify the team on Slack.

## Steps

### 1. Resolve the feature ID

Determine the feature ID using one of the following, in priority order:

1. **Explicit argument** -- the user provided a feature ID directly.
2. **Branch name** -- parse the current branch (`git branch --show-current`). If it matches the pattern `feature/<id>`, extract `<id>`.

If neither yields a feature ID, ask the user and stop.

### 2. Commit uncommitted changes

Run `git status --porcelain` to check for uncommitted changes (staged or unstaged).

- **If changes exist**: follow the **commit-and-push** skill in **commit** mode. This stages thread-relevant files, commits them per commit conventions, and pushes. The PR in the next step will then include all work.
- **If no changes exist**: skip this step silently and proceed to PR creation.

### 3. Create the pull request

Follow the **create-pull-request** skill, passing:

- **workItemId**: the feature ID resolved in step 1.

The shared skill will identify the repository, gather context, compose the description, and create the PR. **Do not compose or present the Slack message yet** -- the user may want to verify the PR live before notifying the team.

### 4. Transition the work item

Update the work item state to **Code Review**.

When transitioning a Task, Azure DevOps requires `CompletedWork` to be non-empty. Set it to `OriginalEstimate` (or the actual hours spent) and `RemainingWork` to `0`. Read these values from the work item fetched during PR creation.

### 5. Notify the team on Slack

**This step begins only after the PR has been created and the link presented in step 3.** Do not batch this approval with the PR approval -- they are separate interactions.

Defaults:

- Slack workspace: `fundguard.slack.com`
- Permalink format: `https://fundguard.slack.com/archives/<channel_id>/p<ts_without_dot>`

When the user asks to share/send a message to a person by name, look up their Slack user ID via `slack_get_users`. Paginate through all pages using the `cursor` parameter until the user is found or all pages are exhausted. Do not stop after the first page.

Compose a message for the **#team-cinfra** Slack channel, following the **writing-style** skill (using the "Slack and casual messages" register). The message should include:

- A link to the PR (linked on the PR number, per **external-communications** skill).
- A link to the work item (linked on the work item ID).
- A one-line summary of what the change does.

**Present the Slack message to the user for approval before posting.**

#### Agent artifact notification (fgrepo only)

After the channel message is posted, check whether the PR touches agent artifacts. **Skip this sub-step entirely if the repository is not fgrepo.**

Run `git diff <default-branch>...HEAD --name-only` and review the changed file list. A file is an agent artifact if it matches any of the known patterns below **or** if it looks like an agent artifact by name or context.

Known patterns:

- `.cursor/**`
- `.claude/**`
- `**/AGENTS.md`, `**/CLAUDE.md`
- `**/RULE-INDEX*`
- `**/SKILL.md`
- `.cursorrules`, `.github/copilot-instructions.md`, `.gemini/**`

Also flag any file whose purpose is to instruct or configure an AI agent -- prompt templates, LLM system instructions, agent workflow definitions, MCP server configuration, AI-related config files, etc. Use judgment; when uncertain, include rather than exclude.

If agent artifacts are detected, compose a DM to Yaakov Ellis (Slack user ID `U08NR4YBWTS`) with a link to the PR and a note that it includes agent artifact changes. Follow the **writing-style** skill and **external-communications** skill. **Present the DM for user approval before sending.**

### 6. Confirm completion

Print a summary of everything that was done:

- PR link
- Work item link and new state
- Slack channel message confirmation
- Yaakov Ellis DM confirmation (if sent)

### 7. Evolve

Follow the **continuous-improvement** skill.
