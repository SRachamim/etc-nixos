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

- Post each finding as a separate comment thread using `repo_create_pull_request_thread` from the native Azure DevOps MCP. For each finding, provide `repositoryId`, `pullRequestId`, `content`, `filePath`, and the full anchor: `rightFileStartLine`, `rightFileStartOffset`, `rightFileEndLine`, and `rightFileEndOffset`. All four are required together -- the tool rejects a start line without an offset, and a start pair without a matching end pair, including for single-line anchors (set the end line equal to the start line). Offsets are 1-based: use `1` for the start offset and the end line's length plus 1 for the end offset. Compute end offsets for all findings before posting, e.g. `git show "<source-ref>:<path>" | sed -n "<end-line>p" | awk '{print length($0)+1}'`. Anchor to a line with content -- a blank line yields an empty selection in the ADO UI. The tool defaults to `status: "Active"`, which is correct per the **code-review-g** skill.

For follow-up reviews (preceded by `/review-pr-fixes-g`):

**When the PR is fully approved** (see `PR approval status` in the `/review-pr-fixes-g` output):

- **Threads to resolve** (`Fixed`): call `repo_update_pull_request_thread` with `status: "Fixed"` (status updates are always applied).
- **Threads to reactivate** (`Active`): call `repo_update_pull_request_thread` with `status: "Active"`, but **skip** `repo_reply_to_comment` -- no reply text posted.
- **New delta findings**: **skip** posting via `repo_create_pull_request_thread`.
- **Threads unchanged**: no action.

**When the PR is not fully approved** (pending):

- **Threads to resolve** (`Fixed`): call `repo_update_pull_request_thread` with `status: "Fixed"`. No reply needed.
- **Threads to reactivate** (`Active`): call `repo_reply_to_comment` with the follow-up explanation from `/draft-review-g`, then call `repo_update_pull_request_thread` with `status: "Active"`.
- **Threads unchanged**: no action.
- **New delta findings**: post via `repo_create_pull_request_thread` (same as initial review).

**Ordering guarantee**: all comment threads and thread status updates must complete successfully before proceeding to step 5 (Cast vote). If any `repo_create_pull_request_thread`, `repo_update_pull_request_thread`, or `repo_reply_to_comment` call fails, stop and report the error to the user. Do not cast the vote with unposted comments.

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

**Skip this step when the PR is fully approved** (see `PR approval status` in the `/review-pr-fixes-g` output), regardless of whether the review was Slack-originated. The approval gate is already passed; Slack ceremony is unnecessary even if new fixes shipped.

Slack signals are sent on **every** `/submit-review-g` invocation -- including follow-up reviews. Each submission is a new review round; the author must be notified.

**Reaction**: add the appropriate reaction to the original Slack message:

| Verdict | Reaction |
|---------|----------|
| `approve` | `white_check_mark` |
| `comment` | `speech_balloon` |
| `suggest` | `speech_balloon` |
| `reject` | `leftwards_arrow_with_hook` |

Treat `already_reacted` errors as idempotent success. When the verdict differs from a previous round (e.g., upgrading from `comment` to `approve`), remove the stale reaction before adding the new one so the emoji reflects the current verdict.

**Thread reply**: post the reply composed in `/draft-review-g` via `conversations_add_message` with `thread_ts`. A new reply is posted on every round -- do not skip because a previous round already posted one.

### 7. Confirm completion

Print a summary:

- PR link.
- Number of comments posted (or "0 -- approve only").
- Vote cast (or "no vote").
- Slack actions taken (if applicable).
- When actions were skipped due to full approval, note it (e.g., "Slack signals: skipped (PR fully approved)", "Thread replies: skipped (status-only updates applied)").

### 8. Learn from triage

Skip this step when no `/triage-finding-g` invocations with "merge" or "add" decisions exist in the conversation.

When non-skipped triage findings exist, invoke the **codify-review-miss-g** shared skill. It analyzes each miss, proposes targeted improvements to review skills, and persists approved observations.

### 9. Evolve

Follow the **capture-improvement-g** skill.
