# Review Pull Request

Given a PR ID (or inferred from the current branch or a Slack message), perform a structured code review and post feedback.

## Steps

### 1. Resolve the PR

Determine the PR using one of the following, in priority order:

1. **Explicit argument** — the user provided a PR ID directly.
2. **Slack message** — the user shared a Slack message containing a review request. Extract the PR link or ID from the message.
3. **Branch name** — find the active PR whose source branch matches the current branch.

If none yields a PR, ask the user and stop.

### 2. Gather context

- Fetch the PR details (title, description, source and target branches).
- Fetch linked work items to understand the intent, acceptance criteria, and scope.
- List the PR's commits and changed files.

### 3. Read the diff

- Read the full diff, commit by commit.
- For each changed file, read enough surrounding context to understand the change.

### 4. Evaluate

Apply the **code-review** skill for general review standards.

Additionally:

- Apply the **functional-typescript** skill if the PR contains TypeScript files.
- Apply the **commit-conventions** skill to evaluate commit structure and hygiene.
- Check against any workspace-level rules defined in the target repository.

### 5. Draft review comments

Structure comments by severity, following the **code-review** skill:

- **Blocking** — must be resolved before merge.
- **Suggestion** — recommended improvement, non-blocking.
- **Nit** — minor style or preference, non-blocking.
- **Praise** — highlight good patterns worth reinforcing.

For each comment, reference the specific file and line range.

### 6. Present the review

Show the complete review to the user, including:

- An overall summary (approve, request changes, or comment-only).
- All comments grouped by severity.

**Wait for user approval before posting** (per **require-message-approval** skill).

### 7. Post the review

- Create comment threads on the PR for each review comment, positioned on the relevant file and line range.
- Follow the **message-formatting** skill for all comment content.

### 8. Confirm completion

Print a summary:

- PR link
- Number of comments posted by severity
- Overall verdict (approved, changes requested, or commented)
