# Review Fixes

Follow up on a previous `/review-pr` or `/review-plan` review within the same conversation. Check whether the author addressed the original findings, evaluate any new content (commits or revised plan steps), and present follow-up feedback. This command must run in the same Cursor thread as the preceding review invocation -- the conversation context is the primary source of truth for what was reviewed and why.

## Conversation-context requirement

The conversation history provides one of two context shapes, depending on which review command preceded this one.

### PR review context (after `/review-pr`)

- The **PR identity** (repository, PR ID, source/target branches) -- already resolved.
- The **original review output** -- every comment the agent drafted, including its severity, the file/line it targeted, and the specific concern it raised.
- The **verdict** from the initial review (approve, request changes, comment-only).
- The **design evaluation** (if step 4 of `/review-pr` was applied) -- reconstructed plan, design-level findings.

### Plan review context (after `/review-plan`)

- The **plan under review** in its normalised form (summary, goal, implementation steps).
- The **original review output** -- every finding the agent drafted, including its severity, the step it targeted, and the specific concern it raised.
- The **verdict** from the initial review (approve, request changes, comment-only).
- The **ticket reference** (if one was used to anchor the review).
- The **suggested revised steps** (if blocking issues led to a corrected step table).

Use this context as the primary source of truth for what was previously reviewed and why. The posted thread text (PR path) or presented findings (plan path) are compressed versions of the original concerns -- the conversation context preserves the full reasoning.

If the agent cannot find a prior `/review-pr` or `/review-plan` execution in the conversation, tell the user and stop. If both exist, use the most recent one. If ambiguous, ask the user which review to follow up on.

## Repository-specific scope

Applies only to the **PR review path**. Some repositories require reviewing only a subset of changed files. When the PR belongs to a scoped repository, **ignore** all files outside the listed paths -- do not read, evaluate, or comment on them.

| Repository | Included paths | Excluded (examples) |
|---|---|---|
| `fgrepo` | `client/` | `devops/`, `automation/`, `backend/`, and anything else outside `client/` |

## Steps

### 1. Recall the review from context

Inspect the conversation history to determine which review command preceded this one and extract the relevant context.

#### When following up on `/review-pr`

Extract the PR identity from the conversation history. No re-resolution needed -- the PR ID, repository, and branches are already known.

If the user provides an explicit PR ID that differs from the one in context, use the explicit ID and warn that the conversation context won't apply (the command will behave as a fresh review in that case).

#### When following up on `/review-plan`

Extract the original plan (normalised form), the verdict, all findings (blocking/suggestion/observation with their step references), suggested revised steps (if any), and the ticket reference (if one was used).

### 2. Establish the review baseline

#### When following up on `/review-pr`

Use the conversation context to determine what was already reviewed:

- The agent knows exactly which comments it posted and when. The last posted comment's timestamp is the baseline.
- List all commits on the PR and partition them into "previously reviewed" (before the baseline) and "new" (after the baseline).

#### When following up on `/review-plan`

The original review's findings list is the baseline. Each finding (with its severity, step reference, and full reasoning) represents a point the author was expected to address.

### 3. Gather current state

#### When following up on `/review-pr`

Fetch all threads on the PR via `repo_list_pull_request_threads`. For every thread the reviewer authored, fetch the full conversation (`repo_list_pull_request_thread_comments`) and record:

- **Current status**: Active, Fixed, WontFix, Closed, ByDesign, Pending.
- **Author replies**: any responses added since the reviewer's last comment.
- **Code context**: the file and line range the thread targets.
- **Original intent**: match each thread back to the corresponding comment in the conversation context to recover the full reasoning and severity behind the original concern.

Also note any new threads created by the author or other reviewers since the baseline.

#### When following up on `/review-plan`

Obtain the revised plan. Accept **any** of the following (same input modes as `/review-plan`):

1. **Inline** -- the user pastes or quotes the revised plan directly.
2. **Document or link** -- a revised plan document.
3. **Ticket reference** -- if the original review used a ticket, re-fetch the work item to pick up description or attachment changes.

If the user does not proactively provide the revised plan, ask for it before proceeding.

### 4. Read the delta

#### When following up on `/review-pr`

- If the repository has a scope filter (see **Repository-specific scope** above), discard changed files outside the included paths before proceeding.
- Read only the new commits (post-baseline).
- For files touched by the delta, read enough surrounding context to understand the change.

#### When following up on `/review-plan`

Diff the revised plan against the original normalised form from the conversation context. Identify:

- **Changed steps** -- steps whose description, scope, or key files differ from the original.
- **Added steps** -- new steps not present in the original plan.
- **Removed steps** -- steps from the original that were dropped.
- **Unchanged steps** -- steps that remain identical (skip these unless an original finding targeted them).

### 5. Evaluate resolutions

#### When following up on `/review-pr`

For each thread the reviewer authored, assess the resolution against the **original intent** from the conversation context (not just the posted comment text):

- **Fixed / Closed**: verify the code at that location actually addresses the original concern. If the fix is adequate, accept. If not, draft a follow-up explaining what's still missing.
- **WontFix / ByDesign**: evaluate the author's reasoning in their reply against the severity and rationale from the original review. If acceptable, acknowledge. If not, explain why and push back.
- **Pending**: check if the author replied but didn't change status. Flag if action is needed.
- **Active**: check if new code or a reply addresses it implicitly. Flag if still outstanding.

Apply the same review principles: **code-review** skill, **functional-typescript** skill (for TS files), **commit-conventions** skill.

#### When following up on `/review-plan`

For each original finding, check whether the revised plan addresses it:

- **Addressed**: the revised step resolves the concern. Accept and note what changed.
- **Partially addressed**: the revision makes progress but doesn't fully resolve the concern. Draft a follow-up explaining what's still missing.
- **Not addressed**: the step is unchanged or the concern is still present. Flag as still outstanding, restating the original reasoning.
- **Disputed**: the author's revision or inline commentary argues against the finding. Evaluate their reasoning against the severity and rationale from the original review. If acceptable, acknowledge. If not, explain why and push back.

Apply the same review principles: **design-lenses** skill, **decision-priorities** skill, **commit-conventions** skill.

### 6. Evaluate new content

#### When following up on `/review-pr`

Apply the full `/review-pr` evaluation to the delta commits:

- Code evaluation per the **code-review** skill.
- Design evaluation (step 4 of `/review-pr`) if the delta warrants it -- consider the design context from the original review's evaluation if it was performed.
- **functional-typescript** skill for TypeScript files.
- **commit-conventions** skill for new commits.
- Check against any workspace-level rules defined in the target repository.

#### When following up on `/review-plan`

Apply the full `/review-plan` evaluation to added and changed steps:

- Design evaluation per the **design-lenses** skill and **decision-priorities** skill.
- Commit structure evaluation per the **commit-conventions** skill.
- Gap analysis: missing steps, missing validation, unacknowledged risks, ticket misalignment.
- If the original review used a ticket, re-check acceptance criteria against the revised plan.

### 7. Draft follow-up

Apply the **writing-style** skill (using the "Code review comments" register for inline comments and the "PR / MR comments" register for summaries when on the PR path; using the standard prose register when on the plan path).

Two categories of output:

- **Finding follow-ups**: responses to original findings where the resolution is inadequate or needs acknowledgement.
- **New findings**: issues found in the delta that weren't caught before.

Categorise by severity per the **code-review** skill:

- **Blocking** -- must be resolved before merge (PR path) or implementation (plan path).
- **Suggestion** -- recommended improvement, non-blocking.
- **Nit** -- minor style or preference, non-blocking.

Don't draft comments for praise -- note praiseworthy patterns in the overall summary instead (step 8).

### 8. Present the review

Show the complete follow-up review to the user.

#### When following up on `/review-pr`

- A summary of thread resolution outcomes (how many accepted, how many need follow-up, grouped by original severity).
- Thread-level findings with the proposed reply and status change for each.
- New delta findings grouped by severity.
- Overall verdict: approve, request further changes, or comment-only.

#### When following up on `/review-plan`

Use the same output format as step 7 of `/review-plan`:

- A summary of finding resolution outcomes (how many accepted, how many need follow-up, grouped by original severity).
- Finding-level follow-ups with the proposed response for each.
- New findings from the delta grouped by severity.
- Overall verdict: approve, request further changes, or comment-only.
- Suggested revised steps (if blocking issues remain).

**Wait for user approval before posting** (per **external-communications** skill).

### 9. Post the review

#### When following up on `/review-pr`

- For thread follow-ups: use `repo_reply_to_comment` to reply and `repo_update_pull_request_thread` to change status where approved.
- For new issues: use `repo_create_pull_request_thread` to create new threads.
- Follow the **external-communications** skill for all comment content.

#### When following up on `/review-plan`

- If the original review was anchored to a ticket, post a summary comment on the work item via MCP.
- Otherwise, the review is presented inline only -- no external posting needed.
- Follow the **external-communications** skill for any posted content.

### 10. Confirm completion

Print a summary matching the context type.

#### When following up on `/review-pr`

- PR link
- Threads reviewed and their outcomes (accepted, pushed back, re-activated)
- New comments posted by severity
- Overall verdict (approved, changes requested, or commented)

#### When following up on `/review-plan`

- Ticket link (if applicable)
- Findings reviewed and their outcomes (accepted, pushed back, still outstanding)
- New findings by severity
- Overall verdict (approved, changes requested, or commented)

### 11. Evolve

Follow the **continuous-improvement** skill.
