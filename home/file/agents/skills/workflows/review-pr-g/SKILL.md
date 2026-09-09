---
name: review-pr-g
description: "Performs a structured code review on a pull request and presents raw findings. Use when given a PR ID, inferred from the current branch, or extracted from a Slack message. Follow up with /triage-finding-g, /draft-review-g, and /submit-review-g to compose and post."
disable-model-invocation: true
---

# Review PR

Given a PR ID (or inferred from the current branch or a Slack message), perform a structured code review and present raw findings. This is the first step of the review pipeline -- follow up with `/triage-finding-g` (optional, per manual note), `/draft-review-g`, and `/submit-review-g` to compose and post the review.

## Repository-specific scope

Some repositories require reviewing only a subset of changed files. When the PR belongs to a scoped repository, **ignore** all files outside the listed paths -- do not read, evaluate, or comment on them.

| Repository | Included paths | Excluded (examples) |
|---|---|---|
| `fgrepo` | `client/` | `devops/`, `automation/`, `backend/`, and anything else outside `client/` |

## Diff scope

**Only files present in the PR's git diff are in scope for review.** Do not treat open editor tabs, recently viewed files, IDE-attached context, or any other workspace state as part of the PR. The git commands in step 2 are the sole authority on which files and commits belong to the PR.

## Slack reaction signals

When the PR was resolved from a Slack message, react to signal the review has started. This reaction appears as the user's own (the Slack token is a user token) and requires no additional approval -- the user opted in by invoking the workflow with a Slack link.

| Moment | Reaction | When it fires |
|--------|----------|---------------|
| Starting review | `eyes` | Immediately after parsing the Slack link (step 2) |

Treat `already_reacted` errors as idempotent success.

Post-review Slack signals (`:speech_balloon:`, thread replies, etc.) are handled by `/submit-review-g`.

## Steps

### 1. Resolve the PR

Determine the PR using one of the following, in priority order:

1. **Explicit argument** -- the user provided a PR ID directly.
2. **Slack message** -- the user shared a Slack message containing a review request. Extract the PR link or ID from the message.
3. **Branch name** -- find the active PR whose source branch matches the current branch.

If none yields a PR, ask the user and stop.

### 2. Gather context

- Fetch the PR details (source and target branches) via `repo_get_pull_request_by_id`. PR title and description are fetched for navigation only -- they are not review inputs (see the **code-review-g** skill's Review Inputs section).
- **If the PR was resolved from a Slack message** (step 1, option 2):
  - Parse the Slack link to extract `channel_id` and `thread_ts` (insert dot before last 6 digits of the `p`-prefixed timestamp).
  - React to the Slack message with `eyes` to signal the review has started (see **Slack reaction signals**). Call `reactions_add` with the extracted `channel_id`, the message `timestamp`, and `emoji: "eyes"`.
  - Call `conversations_replies` with the extracted `channel_id` and `thread_ts` to retrieve the full thread.
  - If there are no thread replies, call `conversations_history` scoped around the timestamp to capture surrounding messages for context.
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

#### Check for existing solutions

When the PR introduces a new abstraction (component, hook, utility, module, service), search the codebase for existing abstractions that address the same problem. Look for:

- Same domain concept under a different name.
- Same structural pattern applied to a related use case (e.g. collapsing header vs. collapsing footer).
- Utility functions or hooks that already encapsulate the logic being re-implemented.

If a match exists, evaluate whether the PR should **reuse** the existing abstraction, **compose** with it, or **generalize** it into a shared solution. A new abstraction that reimplements logic already present elsewhere is a design finding (severity: Suggestion or Blocking depending on the degree of duplication).

#### Research prior art

Apply the **prior-art-research-g** skill to check whether established patterns or approaches exist for the problem domain the PR addresses. Compare the PR's approach against known patterns from the FP, DDD, and software design literature. Note whether the PR aligns with, adapts, or departs from established solutions.

#### Apply the design lenses

Apply the **design-lenses-g** skill using the **review framing** for all three lenses (refactoring, flexibility, architecture). Apply the **decision-priorities-g** skill to check whether the chosen approach respects the priority ordering (correctness > changeability > DX, governed by simplicity).

#### Gap analysis

- **Missing steps** -- work the PR implies but doesn't include (e.g. a migration, a config change, an export update).
- **Unacknowledged risks** -- breaking changes, performance implications, or edge cases the commits don't account for.

### 5. Evaluate code

Apply the **code-review-g** skill for general review standards.

Additionally:

- Apply the **functional-typescript-g** skill if the PR contains TypeScript files.
- Apply the **commit-conventions-g** skill to evaluate commit structure and hygiene.
- **Load relevant workspace rules**: the target repository may define conditional workspace rules (rules scoped to specific file patterns or content domains) that don't auto-load during review -- the agent reads diffs via git commands rather than opening files through the editor, so path-based triggers may not fire. Scan available conditional workspace rules and load any whose scope matches changed files or content in the diff (e.g. CSS rules for stylesheet changes, React hook rules for hook changes, form rules for form component changes). Always-applied rules are already in context.
- **fgrepo client/ quality gate**: When the PR belongs to fgrepo and includes changed files under `client/`, read the repo-level `client-code-quality-gate` skill (`client/.cursor/skills/development/client-code-quality-gate/SKILL.md`) and apply its verification checks (Sections A--C) to each changed client/ file during code evaluation. Quality gate checks are conditional on each check's "When to run" trigger -- skip checks whose trigger does not apply. Map quality gate severity to review findings: `blocking` items become blocking review findings, `warning` items become suggestions. This loading is mandatory -- do not rely on path-based auto-discovery.

### 6. Present raw findings

List each finding identified in steps 4--5 with its internal severity tag, file path, line range, and issue description. Use a lightweight internal format -- no **delivered-text-g** composition, no fenced code blocks of literal post text.

For each finding, include:

- **Severity** (internal): Blocking, Suggestion, or Nit.
- **File path and line range**: the specific location in the diff.
- **Issue description**: what the problem is, why it matters, and the concrete alternative.

Include the design evaluation summary (if step 4 ran): the reconstructed plan and any design-level findings.

**Verification**: count listed findings against issues identified in steps 4--5. If any issue lacks a corresponding finding, add it now.

This output becomes the input for `/triage-finding-g` (if the user has manual notes) or `/draft-review-g` (if not).

### 7. Evolve

Follow the **capture-improvement-g** skill.
