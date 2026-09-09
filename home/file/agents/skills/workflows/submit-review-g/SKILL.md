---
name: submit-review-g
description: "Post review findings to ADO and optionally cast a vote, based on a single keyword verdict (approve, comment, reject, suggest). Reads composed findings from a preceding /draft-review-g. Use as the final step of the review pipeline, after /draft-review-g."
disable-model-invocation: true
---

# Submit Review

Post review findings to ADO and optionally cast a vote, based on a single keyword argument.

This skill is the terminal step of the review pipeline. It takes the composed findings from `/draft-review-g` and executes the external actions: posting comment threads, managing thread status, casting a vote, and sending Slack signals.

## Input

A single keyword -- the review verdict:

| Keyword | Post findings | Vote | When to use |
|---------|---------------|------|-------------|
| `approve` | No | Approve (10) via **vote-pr-g** | Clean review, no comments needed |
| `comment` | Yes | None | Advisory feedback, don't block the author |
| `reject` | Yes | Reject (-10) via **vote-pr-g** | Blocking issues found |
| `suggest` | Yes | Approve with suggestions (5) via **vote-pr-g** | Non-blocking feedback, still LGTM overall |

`approve` intentionally skips posting findings. If you want to approve AND post nits, use `suggest` instead.

## Steps

### 1. Parse verdict

Read the keyword from the user's invocation. If missing or invalid, ask.

### 2. Validate context

Verify the conversation contains a `/draft-review-g` output with composed findings. If not, tell the user to run `/draft-review-g` first and stop.

Also extract the PR identity (repository ID, PR ID, source/target branches) from the conversation -- it was resolved in the preceding `/review-pr-g` or `/review-pr-fixes-g`.

### 3. Confirm external action

Per **external-communications-g**, show what will happen:

- Number of comments to post (or "none" for `approve`).
- Vote value and label (or "no vote" for `comment`).
- Thread status changes (if follow-up review): N threads to resolve, N to reactivate.
- Slack actions (if Slack-originated): reaction emoji and thread reply text.

The literal comment text was already approved in `/draft-review-g` -- this confirmation covers the posting action and vote, not the content.

Wait for user approval before proceeding.

### 4. Post findings

Skip this step when verdict is `approve`.

For initial reviews (preceded by `/review-pr-g`):

- Post each finding as a separate comment thread using `repo_create_pull_request_thread` from the native Azure DevOps MCP. For each finding, provide `repositoryId`, `pullRequestId`, `content`, `filePath`, and `rightFileStartLine` (with `rightFileEndLine` when the finding spans multiple lines). The tool defaults to `status: "Active"`, which is correct per the **code-review-g** skill.

For follow-up reviews (preceded by `/review-pr-fixes-g`):

- **Threads to resolve** (`Fixed`): call `repo_update_pull_request_thread` with `status: "Fixed"`. No reply needed.
- **Threads to reactivate** (`Active`): call `repo_reply_to_comment` with the follow-up explanation from `/draft-review-g`, then call `repo_update_pull_request_thread` with `status: "Active"`.
- **Threads unchanged**: no action.
- **New delta findings**: post via `repo_create_pull_request_thread` (same as initial review).

### 5. Cast vote

Skip this step when verdict is `comment`.

Delegate to **vote-pr-g** with the PR identity and vote value:

| Verdict | Vote value |
|---------|-----------|
| `approve` | `approve` (10) |
| `reject` | `reject` (-10) |
| `suggest` | `approve-with-suggestions` (5) |

### 6. Slack signals

Skip this step when the review was not Slack-originated.

Add the appropriate reaction to the original Slack message:

| Verdict | Reaction |
|---------|----------|
| `approve` | `white_check_mark` |
| `comment` | `speech_balloon` |
| `suggest` | `speech_balloon` |
| `reject` | `leftwards_arrow_with_hook` |

Treat `already_reacted` errors as idempotent success.

Post the thread reply composed in `/draft-review-g` via `conversations_add_message` with `thread_ts`.

### 7. Confirm completion

Print a summary:

- PR link.
- Number of comments posted (or "0 -- approve only").
- Vote cast (or "no vote").
- Slack actions taken (if applicable).

### 8. Evolve

Follow the **capture-improvement-g** skill.
