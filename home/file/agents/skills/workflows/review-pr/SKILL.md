---
name: review-pr
description: Performs a structured code review on a pull request and posts feedback. Use when given a PR ID, inferred from the current branch, or extracted from a Slack message.
disable-model-invocation: true
---

# Review Pull Request

Given a PR ID (or inferred from the current branch or a Slack message), perform a structured code review and post feedback.

## Repository-specific scope

Some repositories require reviewing only a subset of changed files. When the PR belongs to a scoped repository, **ignore** all files outside the listed paths -- do not read, evaluate, or comment on them.

| Repository | Included paths | Excluded (examples) |
|---|---|---|
| `fgrepo` | `client/` | `devops/`, `automation/`, `backend/`, and anything else outside `client/` |

## Diff scope

**Only files present in the PR's git diff are in scope for review.** Do not treat open editor tabs, recently viewed files, IDE-attached context, or any other workspace state as part of the PR. The git commands in step 2 are the sole authority on which files and commits belong to the PR.

## Slack reaction signals

When the PR was resolved from a Slack message, react to the original message at key milestones. These reactions appear as the user's own (the Slack token is a user token) and require no additional approval -- the user opted in by invoking the workflow with a Slack link.

| Moment | Reaction | When it fires |
|--------|----------|---------------|
| Starting review | `eyes` | Immediately after parsing the Slack link (step 2) |
| Approved | `white_check_mark` | After the PR is approved on the platform, or the user confirms they approved |
| Reviewed with comments | `speech_balloon` | After review comments are posted to the PR, or the user confirms they posted |

Treat `already_reacted` errors as idempotent success. Do not attempt to remove earlier reactions -- accumulating them tells the review lifecycle story.

## Steps

### 1. Resolve the PR

Determine the PR using one of the following, in priority order:

1. **Explicit argument** -- the user provided a PR ID directly.
2. **Slack message** -- the user shared a Slack message containing a review request. Extract the PR link or ID from the message.
3. **Branch name** -- find the active PR whose source branch matches the current branch.

If none yields a PR, ask the user and stop.

### 2. Gather context

- Fetch the PR details (source and target branches) via `repo_get_pull_request_by_id`. PR title and description are fetched for navigation only -- they are not review inputs (see the **code-review** skill's Review Inputs section).
- **If the PR was resolved from a Slack message** (step 1, option 2):
  - Parse the Slack link to extract `channel_id` and `thread_ts` (insert dot before last 6 digits of the `p`-prefixed timestamp).
  - React to the Slack message with `eyes` to signal the review has started (see **Slack reaction signals**). Call `slack_add_reaction` with the extracted `channel_id`, the message `timestamp`, and `reaction: "eyes"`.
  - Call `slack_get_thread_replies` with the extracted `channel_id` and `thread_ts` to retrieve the full thread.
  - If there are no thread replies, call `slack_get_channel_history` scoped around the timestamp to capture surrounding messages for context.
  - Scan the thread/surrounding messages for:
    - **Reviewer notes** -- specific areas to focus on, known concerns, or questions.
    - **Urgency signals** -- time pressure, blocking status, or deployment deadlines.
    - **Related links** -- additional PRs, work items, or documents referenced in the conversation.
  - Incorporate any findings into the review scope -- e.g. if the requester asks "please check the error handling in X", prioritise that area during steps 4-5.
- Verify the current workspace is the PR's repository. If not, stop and ask the user to switch.
- Run `git fetch origin` to ensure remote refs are current.
- List PR commits: `git log --oneline origin/<target>..origin/<source>` (two-dot -- commits reachable from source but not target).
- List changed files: `git diff --name-only origin/<target>...origin/<source>` (three-dot merge-base syntax -- only changes introduced by the source branch).
- These commands are the sole authority on the PR's scope (see **Diff scope** above).

### 3. Read the diff

- If the repository has a scope filter (see **Repository-specific scope** above), discard changed files outside the included paths before proceeding.
- Read each PR commit individually using `git show <sha>` for a commit-by-commit view.
- Alternatively, read the full PR diff using `git diff origin/<target>...origin/<source>` when a holistic view is more useful.
- For each changed file, use `Read` to examine surrounding context beyond the diff hunks where needed to understand the change.

### 4. Evaluate design

Skip this step entirely when:

- The PR is trivial -- a single commit touching one module with no restructuring or design decisions.
- An approved tech-design plan already exists for this work and is visible in the commit history or a preceding `/review-plan` outcome. If the design was already reviewed and accepted, the PR review focuses on implementation correctness (step 5) rather than re-evaluating architecture.

Apply the full design evaluation when the code (as read in step 3) exhibits architectural significance -- any of the following hold:

- Introduces new architectural patterns, abstractions, or data flows not already present in the codebase.
- Deviates from established codebase conventions (non-standard approaches to a problem the codebase already solves elsewhere).
- Makes design decisions that set precedent -- future code will likely follow the pattern introduced here.
- Changes how components interact, introduces new integration points, or reshapes domain boundaries.

Supporting quantitative signals (not sufficient on their own, but reinforce the assessment):

- The PR contains 3 or more commits.
- Changes span 2 or more modules or packages.
- Commits include restructuring (refactor-prefixed messages, large file moves or renames).

#### Reconstruct the implicit plan

From the commit sequence, infer:

- The **goal** -- what the PR is trying to achieve.
- The **target state** -- what the codebase should look like after the PR lands.
- The **ordering strategy** -- are refactorings separated from behaviour changes? Are tests added before the code they protect?
- The **design decisions** -- what alternatives were implicitly rejected by the chosen approach.

#### Research prior art

Apply the **prior-art-research** skill to check whether established patterns or approaches exist for the problem domain the PR addresses. Compare the PR's approach against known patterns from the FP, DDD, and software design literature. Note whether the PR aligns with, adapts, or departs from established solutions.

#### Apply the design lenses

Apply the **design-lenses** skill using the **review framing** for all three lenses (refactoring, flexibility, architecture). Apply the **decision-priorities** skill to check whether the chosen approach respects the priority ordering (correctness > changeability > DX, governed by simplicity).

#### Gap analysis

- **Missing steps** -- work the PR implies but doesn't include (e.g. a migration, a config change, an export update).
- **Unacknowledged risks** -- breaking changes, performance implications, or edge cases the commits don't account for.

### 5. Evaluate code

Apply the **code-review** skill for general review standards.

Additionally:

- Apply the **functional-typescript** skill if the PR contains TypeScript files.
- Apply the **commit-conventions** skill to evaluate commit structure and hygiene.
- Check against any workspace-level rules defined in the target repository.

### 6. Draft review comments

Read and apply the **external-communications** skill before composing the text below. Apply the **objective-communication** skill to all review comments.

Draft a comment for **every** issue found, categorised by severity per the **code-review** skill:

- **Blocking** -- must be resolved before merge.
- **Suggestion** -- recommended improvement, non-blocking.
- **Nit** -- minor style or preference, non-blocking.

Do not include praise. Every comment and summary item must be actionable.

For each comment, reference the specific file and line range.

### 7. Present the review

Show the complete review to the user, including:

- An overall summary (approve, request changes, or comment-only).
- **Design evaluation** (when step 4 was applied):
  - The reconstructed plan (brief: goal, approach, commit strategy).
  - Design-level findings, categorised by severity.
- All code-level comments grouped by severity.

**Wait for user approval before posting** (per **external-communications** skill).

### 8. Post the review

- Create comment threads on the PR for each review comment, positioned on the relevant file and line range.
- **If the PR was resolved from a Slack message**, react to the original message based on the outcome (see **Slack reaction signals**):
  - If the overall verdict is **approve** (PR approved on the platform, or the user confirms they approved): call `slack_add_reaction` with `reaction: "white_check_mark"`.
  - If review comments were posted (or the user confirms they posted): call `slack_add_reaction` with `reaction: "speech_balloon"`.
  - Fire these reactions only after the corresponding external action is confirmed -- never preemptively from step 7.
  - If the user later confirms they took the action manually (e.g. "I approved" or "I posted the comments"), add the appropriate reaction at that point.

### 9. Confirm completion

Print a summary:

- PR link
- Number of comments posted by severity
- Overall verdict (approved, changes requested, or commented)

### 10. Evolve

Follow the **continuous-improvement** skill.
