# Review PR Fixes

Follow up on a previous `/review-pr` review within the same conversation. Fetch the current state of every comment thread, read author replies and status changes, review the delta diff (new commits since the last review), and post follow-up feedback. This command must run in the same Cursor thread as the preceding `/review-pr` invocation -- the conversation context is the primary source of truth for what was reviewed and why.

## Conversation-context requirement

The conversation history provides:

- The **PR identity** (repository, PR ID, source/target branches) -- already resolved.
- The **original review output** -- every comment the agent drafted, including its severity, the file/line it targeted, and the specific concern it raised.
- The **verdict** from the initial review (approve, request changes, comment-only).
- The **design evaluation** (if step 4 of `/review-pr` was applied) -- reconstructed plan, design-level findings.

Use this context as the primary source of truth for what was previously reviewed and why. The posted thread text is a compressed version of the original concern -- the conversation context preserves the full reasoning.

If the agent cannot find a prior `/review-pr` execution in the conversation, tell the user and stop.

## Repository-specific scope

Some repositories require reviewing only a subset of changed files. When the PR belongs to a scoped repository, **ignore** all files outside the listed paths -- do not read, evaluate, or comment on them.

| Repository | Included paths | Excluded (examples) |
|---|---|---|
| `fgrepo` | `client/` | `devops/`, `automation/`, `backend/`, and anything else outside `client/` |

## Steps

### 1. Recall the PR from context

Extract the PR identity from the conversation history (the prior `/review-pr` run). No re-resolution needed -- the PR ID, repository, and branches are already known.

If the user provides an explicit PR ID that differs from the one in context, use the explicit ID and warn that the conversation context won't apply (the command will behave as a fresh review in that case).

### 2. Establish the review baseline

Use the conversation context to determine what was already reviewed:

- The agent knows exactly which comments it posted and when. The last posted comment's timestamp is the baseline.
- List all commits on the PR and partition them into "previously reviewed" (before the baseline) and "new" (after the baseline).

### 3. Gather thread states

Fetch all threads on the PR via `repo_list_pull_request_threads`. For every thread the reviewer authored, fetch the full conversation (`repo_list_pull_request_thread_comments`) and record:

- **Current status**: Active, Fixed, WontFix, Closed, ByDesign, Pending.
- **Author replies**: any responses added since the reviewer's last comment.
- **Code context**: the file and line range the thread targets.
- **Original intent**: match each thread back to the corresponding comment in the conversation context to recover the full reasoning and severity behind the original concern.

Also note any new threads created by the author or other reviewers since the baseline.

### 4. Read the delta diff

- If the repository has a scope filter (see **Repository-specific scope** above), discard changed files outside the included paths before proceeding.
- Read only the new commits (post-baseline).
- For files touched by the delta, read enough surrounding context to understand the change.

### 5. Evaluate thread resolutions

For each thread the reviewer authored, assess the resolution against the **original intent** from the conversation context (not just the posted comment text):

- **Fixed / Closed**: verify the code at that location actually addresses the original concern. If the fix is adequate, accept. If not, draft a follow-up explaining what's still missing.
- **WontFix / ByDesign**: evaluate the author's reasoning in their reply against the severity and rationale from the original review. If acceptable, acknowledge. If not, explain why and push back.
- **Pending**: check if the author replied but didn't change status. Flag if action is needed.
- **Active**: check if new code or a reply addresses it implicitly. Flag if still outstanding.

Apply the same review principles: **code-review** skill, **functional-typescript** skill (for TS files), **commit-conventions** skill.

### 6. Evaluate new code in the delta

Apply the full `/review-pr` evaluation to the delta commits:

- Code evaluation per the **code-review** skill.
- Design evaluation (step 4 of `/review-pr`) if the delta warrants it -- consider the design context from the original review's evaluation if it was performed.
- **functional-typescript** skill for TypeScript files.
- **commit-conventions** skill for new commits.
- Check against any workspace-level rules defined in the target repository.

### 7. Draft follow-up comments

Apply the **writing-style** skill (using the "Code review comments" register for inline comments and the "PR / MR comments" register for the overall summary).

Two categories of output:

- **Thread follow-ups**: replies to existing threads where the resolution is inadequate or needs acknowledgement. Include recommended status changes (e.g. re-activate a prematurely resolved thread).
- **New comments**: issues found in the delta that weren't caught before.

Categorise by severity per the **code-review** skill:

- **Blocking** -- must be resolved before merge.
- **Suggestion** -- recommended improvement, non-blocking.
- **Nit** -- minor style or preference, non-blocking.

Don't draft comments for praise -- note praiseworthy patterns in the overall summary instead (step 8).

### 8. Present the review

Show the complete follow-up review to the user, including:

- A summary of thread resolution outcomes (how many accepted, how many need follow-up, grouped by original severity).
- Thread-level findings with the proposed reply and status change for each.
- New delta findings grouped by severity.
- Overall verdict: approve, request further changes, or comment-only.

**Wait for user approval before posting** (per **external-communications** skill).

### 9. Post the review

- For thread follow-ups: use `repo_reply_to_comment` to reply and `repo_update_pull_request_thread` to change status where approved.
- For new issues: use `repo_create_pull_request_thread` to create new threads.
- Follow the **external-communications** skill for all comment content.

### 10. Confirm completion

Print a summary:

- PR link
- Threads reviewed and their outcomes (accepted, pushed back, re-activated)
- New comments posted by severity
- Overall verdict (approved, changes requested, or commented)

### 11. Evolve

Follow the **continuous-improvement** skill.
