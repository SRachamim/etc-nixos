# Review Pull Request

Given a PR ID (or inferred from the current branch or a Slack message), perform a structured code review and post feedback.

## Repository-specific scope

Some repositories require reviewing only a subset of changed files. When the PR belongs to a scoped repository, **ignore** all files outside the listed paths -- do not read, evaluate, or comment on them.

| Repository | Included paths | Excluded (examples) |
|---|---|---|
| `fgrepo` | `client/` | `devops/`, `automation/`, `backend/`, and anything else outside `client/` |

## Diff scope

**Only files present in the PR's git diff are in scope for review.** Do not treat open editor tabs, recently viewed files, IDE-attached context, or any other workspace state as part of the PR. The git commands in step 2 are the sole authority on which files and commits belong to the PR.

## Steps

### 1. Resolve the PR

Determine the PR using one of the following, in priority order:

1. **Explicit argument** -- the user provided a PR ID directly.
2. **Slack message** -- the user shared a Slack message containing a review request. Extract the PR link or ID from the message.
3. **Branch name** -- find the active PR whose source branch matches the current branch.

If none yields a PR, ask the user and stop.

### 2. Gather context

- Fetch the PR details (title, description, source and target branches) via `repo_get_pull_request_by_id`.
- For each linked work item, apply the **work-item-context** skill to gather the full picture -- relations, linked PRs, hyperlinks, and comments. Use the skill's structured summary to understand the intent, acceptance criteria, and scope.
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

Skip this step when the PR is trivial -- a single commit touching one module with no restructuring. Apply the full design evaluation when any of the following hold:

- The PR contains 3 or more commits.
- Changes span 2 or more modules or packages.
- Commits include restructuring (refactor-prefixed messages, large file moves or renames).

#### Reconstruct the implicit plan

From the commit sequence, infer:

- The **goal** -- what the PR is trying to achieve.
- The **target state** -- what the codebase should look like after the PR lands.
- The **ordering strategy** -- are refactorings separated from behaviour changes? Are tests added before the code they protect?
- The **design decisions** -- what alternatives were implicitly rejected by the chosen approach.

#### Apply the design lenses

Apply the **design-lenses** skill using the **review framing** for all three lenses (refactoring, flexibility, architecture).

#### Gap analysis

- **Missing steps** -- work the PR implies but doesn't include (e.g. a migration, a config change, an export update).
- **Ticket misalignment** -- acceptance criteria from linked work items that the PR doesn't address.
- **Unacknowledged risks** -- breaking changes, performance implications, or edge cases the commits don't account for.

### 5. Evaluate code

Apply the **code-review** skill for general review standards.

Additionally:

- Apply the **functional-typescript** skill if the PR contains TypeScript files.
- Apply the **commit-conventions** skill to evaluate commit structure and hygiene.
- Check against any workspace-level rules defined in the target repository.

### 6. Draft review comments

Apply the **writing-style** skill (using the "Code review comments" register for inline comments and the "PR / MR comments" register for the overall summary).

Draft a comment for **every** issue found, categorised by severity per the **code-review** skill:

- **Blocking** -- must be resolved before merge.
- **Suggestion** -- recommended improvement, non-blocking.
- **Nit** -- minor style or preference, non-blocking.

Don't draft comments for praise -- note praiseworthy patterns in the overall summary instead (step 7).

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
- Follow the **external-communications** skill for all comment content.

### 9. Confirm completion

Print a summary:

- PR link
- Number of comments posted by severity
- Overall verdict (approved, changes requested, or commented)

### 10. Evolve

Follow the **continuous-improvement** skill.
