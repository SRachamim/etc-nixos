---
name: review-pr-fixes-g
description: "Follows up on a previous /review-pr-g or /review-plan-g review to check whether findings were addressed and evaluate new content. Presents raw findings and resolution status. Use in the same conversation as a preceding review invocation. Follow up with /triage-finding-g, /draft-review-g, and /submit-review-g to compose and post."
disable-model-invocation: true
---

# Review PR Fixes

Follow up on a previous `/review-pr-g` or `/review-plan-g` review within the same conversation. Check whether the author addressed the original findings, evaluate any new content (commits or revised plan steps), and present raw findings and resolution status. This is the analysis step -- follow up with `/triage-finding-g` (optional), `/draft-review-g`, and `/submit-review-g` to compose and post the follow-up review. This command must run in the same agent conversation as the preceding review invocation -- the conversation context is the primary source of truth for what was reviewed and why.

## Conversation-context requirement

The conversation history provides one of two context shapes, depending on which review command preceded this one.

### PR review context (after `/review-pr-g`)

- The **PR identity** (repository, PR ID, source/target branches) -- already resolved.
- The **original review output** -- every comment the agent drafted, including its severity, the file/line it targeted, and the specific concern it raised.
- The **verdict** from the initial review (approve, request changes, comment-only).
- The **design evaluation** (if step 4 of `/review-pr-g` was applied) -- reconstructed plan, design-level findings.

### Plan review context (after `/review-plan-g`)

- The **plan under review** in its normalised form (summary, goal, implementation steps).
- The **original review output** -- every finding the agent drafted, including its severity, the step it targeted, and the specific concern it raised.
- The **verdict** from the initial review (approve, request changes, comment-only).
- The **ticket reference** (if one was used to anchor the review).
- The **suggested revised steps** (if blocking issues led to a corrected step table).

Use this context as the primary source of truth for what was previously reviewed and why. The posted thread text (PR path) or presented findings (plan path) are compressed versions of the original concerns -- the conversation context preserves the full reasoning.

If the agent cannot find a prior `/review-pr-g` or `/review-plan-g` execution in the conversation, tell the user and stop. If both exist, use the most recent one. If ambiguous, ask the user which review to follow up on.

## Repository-specific scope

Applies only to the **PR review path**. Some repositories require reviewing only a subset of changed files. When the PR belongs to a scoped repository, **ignore** all files outside the listed paths -- do not read, evaluate, or comment on them.

| Repository | Included paths | Excluded (examples) |
|---|---|---|
| `fgrepo` | `client/` | `devops/`, `automation/`, `backend/`, and anything else outside `client/` |

## Steps

### 1. Recall the review from context

Inspect the conversation history to determine which review command preceded this one and extract the relevant context.

#### When following up on `/review-pr-g`

Extract the PR identity from the conversation history. No re-resolution needed -- the PR ID, repository, and branches are already known.

If the user provides an explicit PR ID that differs from the one in context, use the explicit ID and warn that the conversation context won't apply (the command will behave as a fresh review in that case).

#### When following up on `/review-plan-g`

Extract the original plan (normalised form), the verdict, all findings (blocking/suggestion/observation with their step references), suggested revised steps (if any), and the ticket reference (if one was used).

### 2. Establish the review baseline

#### When following up on `/review-pr-g`

Use the conversation context to determine what was already reviewed:

- The agent knows exactly which comments it posted and when. The last posted comment's timestamp is the baseline.
- List all commits on the PR and partition them into "previously reviewed" (before the baseline) and "new" (after the baseline).

#### When following up on `/review-plan-g`

The original review's findings list is the baseline. Each finding (with its severity, step reference, and full reasoning) represents a point the author was expected to address.

### 3. Gather current state

#### When following up on `/review-pr-g`

Fetch all threads on the PR via `repo_list_pull_request_threads`. Use `baseIteration` to filter to threads from the iteration after the last reviewed push (this returns only threads created since the baseline, reducing noise). For every thread the reviewer authored, review the full conversation and record:

- **Current status**: Active, Fixed, WontFix, Closed, ByDesign, Pending.
- **Author replies**: any responses added since the reviewer's last comment.
- **Code context**: the file and line range the thread targets.
- **Original intent**: match each thread back to the corresponding comment in the conversation context to recover the full reasoning and severity behind the original concern.

Also note any new threads created by the author or other reviewers since the baseline.

#### When following up on `/review-plan-g`

Obtain the revised plan. Accept **any** of the following (same input modes as `/review-plan-g`):

1. **Inline** -- the user pastes or quotes the revised plan directly.
2. **Document or link** -- a revised plan document.
3. **Ticket reference** -- if the original review used a ticket, re-fetch the work item to pick up description or attachment changes.

If the user does not proactively provide the revised plan, ask for it before proceeding.

### 4. Read the delta

#### When following up on `/review-pr-g`

- Run `git fetch origin <target-branch> <source-branch>` to pick up new commits on both branches. Fetching only the source branch leaves the target stale, which corrupts commit topology analysis (the `origin/<target>..<source>` range includes commits already on the target).
- List post-baseline commits: `git log --oneline <baseline-sha>..origin/<source>` where `<baseline-sha>` is the last commit reviewed and `<source>` is the PR's source branch.
- If the repository has a scope filter (see **Repository-specific scope** above), discard changed files outside the included paths before proceeding.
- Read each new commit individually using `git show <sha>`.
- Only files touched by these post-baseline commits are in scope for the delta evaluation -- do not include files from IDE workspace state, open editors, or other context.
- For files touched by the delta, use `Read` to examine surrounding context beyond the diff hunks where needed.

#### When following up on `/review-plan-g`

Diff the revised plan against the original normalised form from the conversation context. Identify:

- **Changed steps** -- steps whose description, scope, or key files differ from the original.
- **Added steps** -- new steps not present in the original plan.
- **Removed steps** -- steps from the original that were dropped.
- **Unchanged steps** -- steps that remain identical (skip these unless an original finding targeted them).

### 5. Evaluate resolutions

#### When following up on `/review-pr-g`

For each thread the reviewer authored, assess the resolution against the **original intent** from the conversation context (not just the posted comment text). Record a **status decision** for each thread -- every thread must end this step with a target status:

- **Fixed / Closed**: verify the code at that location actually addresses the original concern. If adequate, mark for **resolution** (status -> `Fixed`). If not, draft a follow-up explaining what's still missing and mark for **reactivation** (status -> `Active`).
- **WontFix / ByDesign**: evaluate the author's reasoning in their reply against the severity and rationale from the original review. If acceptable, acknowledge and leave status unchanged. If not, explain why, push back, and mark for **reactivation** (status -> `Active`).
- **Pending / Active**: check if new code or a reply addresses the concern. If resolved, mark for **resolution** (status -> `Fixed`). If still outstanding, flag and keep `Active`.

Apply the same review principles: **code-review-g** skill, **functional-typescript-g** skill (for TS files), **commit-conventions-g** skill.

#### When following up on `/review-plan-g`

For each original finding, check whether the revised plan addresses it:

- **Addressed**: the revised step resolves the concern. Accept and note what changed.
- **Partially addressed**: the revision makes progress but doesn't fully resolve the concern. Draft a follow-up explaining what's still missing.
- **Not addressed**: the step is unchanged or the concern is still present. Flag as still outstanding, restating the original reasoning.
- **Disputed**: the author's revision or inline commentary argues against the finding. Evaluate their reasoning against the severity and rationale from the original review. If acceptable, acknowledge. If not, explain why and push back.

Apply the same review principles: **design-lenses-g** skill, **decision-priorities-g** skill, **commit-conventions-g** skill.

### 6. Evaluate new content

#### When following up on `/review-pr-g`

Any post-baseline modification that was not part of the original review receives a **full from-scratch review** -- the same evaluation as the initial `/review-pr-g`, not a lighter delta check. This includes new files, new hunks in previously reviewed files, and entirely new commits. Apply the full `/review-pr-g` evaluation:

- Code evaluation per the **code-review-g** skill.
- Design evaluation (step 4 of `/review-pr-g`) if the delta warrants it -- consider the design context from the original review's evaluation if it was performed.
- **Adoption completeness** -- when a fix introduces a new abstraction (module, codec, type alias, predicate, utility), sweep **all** PR-changed files for patterns the abstraction was created to replace. A centralization fix that isn't adopted across the PR is incomplete. Search for: ad-hoc inline constructions of the same type (e.g. `t.union([A, B])` when a named codec exists), type annotations spelling out the union manually, inline predicate logic the module encapsulates, and manual refinements when codec-based `.is` is available. Report every remaining instance -- do not stop at a sample.
- **functional-typescript-g** skill for TypeScript files.
- **commit-conventions-g** skill for new commits.
- **Commit hygiene check**: verify no `fixup!` or `squash!` commits remain unsquashed on the branch. A dangling fixup commit is a blocking finding -- the author must interactive-rebase before approval.
- **Load relevant workspace rules**: the target repository may define conditional workspace rules (rules scoped to specific file patterns or content domains) that don't auto-load during review -- the agent reads diffs via git commands rather than opening files through the editor, so path-based triggers may not fire. Scan available conditional workspace rules and load any whose scope matches changed files or content in the diff (e.g. CSS rules for stylesheet changes, React hook rules for hook changes, form rules for form component changes). Always-applied rules are already in context.
- **fgrepo client/ quality gate**: When the PR belongs to fgrepo and the delta includes changed files under `client/`, read the repo-level `client-code-quality-gate` skill (`client/.cursor/skills/development/client-code-quality-gate/SKILL.md`) and apply its verification checks (Sections A--C) to each changed client/ file during delta evaluation. Quality gate checks are conditional on each check's "When to run" trigger -- skip checks whose trigger does not apply. Map quality gate severity to review findings: `blocking` items become blocking review findings, `warning` items become suggestions. This loading is mandatory -- do not rely on path-based auto-discovery.

#### When following up on `/review-plan-g`

Apply the full `/review-plan-g` evaluation to added and changed steps:

- Design evaluation per the **design-lenses-g** skill and **decision-priorities-g** skill.
- Commit structure evaluation per the **commit-conventions-g** skill.
- Gap analysis: missing steps, missing validation, unacknowledged risks, ticket misalignment.
- If the original review used a ticket, re-check acceptance criteria against the revised plan.

### 7. Present raw findings and resolution status

Output the follow-up results directly in the conversation using the structured template below. Do not use `CreatePlan`, plan tools, or external documents -- the output must be inline markdown in the chat so downstream skills (`/triage-finding-g`, `/draft-review-g`) can read it from conversation context.

Use a lightweight internal format -- no **delivered-text-g** composition, no fenced code blocks of literal post text.

#### Output template -- PR review follow-up

Use this template when following up on `/review-pr-g`:

```
## Follow-up Review: [PR #<id>](<ADO PR URL>)

**Baseline commit**: <sha of last commit reviewed>
**New commits**: <count> (<first-new-sha>..<last-new-sha>)
**New/changed files**: <count>

### Thread Resolutions

#### T<thread-id> `src/path/to/file.ts` L42 -- Fixed

<What was verified. Why the fix adequately addresses the original concern.>

#### T<thread-id> `src/path/to/other.ts` L15 -- Reactivated

<What's still missing. Reference to the original concern and what the fix
failed to address.>

#### T<thread-id> `src/path/to/another.ts` L100 -- Unchanged

<Why the current status is acceptable (e.g., author's WontFix reasoning
is valid) or why no action was needed.>

### New Findings

#### F1 [Blocking] `src/path/to/new-file.ts` L25-30

<What the problem is. Why it matters. The concrete alternative.>

#### F2 [Suggestion] `src/path/to/changed.ts` L8

<What the problem is. Why it matters. The concrete alternative.>

### Summary

**Resolutions**: N fixed, N reactivated, N unchanged
**New findings**: N blocking, N suggestions, N nits
**Verdict indicator**: request-changes / comment-only / clean
**Next**: `/triage-finding-g` → `/draft-review-g` → `/submit-review-g`
```

##### Template rules -- PR follow-up

- **PR link** in the `## Follow-up Review` heading must be a clickable markdown link to the ADO PR page (same convention as `/review-pr-g` step 6).
- **Thread resolution headings** use the format `#### T<thread-id> \`file/path\` L<line> -- <Assessment>`. The `T<thread-id>` matches the ADO thread ID so `/submit-review-g` can map resolutions to thread status updates.
- **Assessment** is one of `Fixed` (adequate fix verified -- mark for resolution), `Reactivated` (fix inadequate or missing -- mark for reactivation with follow-up reply), or `Unchanged` (status left as-is, e.g. acceptable WontFix/ByDesign -- no action).
- **New finding headings** use the same `F<n>` format as `/review-pr-g` step 6. New findings from the delta receive a full from-scratch evaluation, not a lighter check.
- **Verdict indicator**: `request-changes` when any new finding is Blocking or any thread is Reactivated, `comment-only` when all new findings are non-blocking and all threads are Fixed/Unchanged, `clean` when there are zero new findings and all threads are Fixed/Unchanged.

#### Output template -- Plan review follow-up

Use this template when following up on `/review-plan-g`:

```
## Follow-up Plan Review

**Plan**: <reference or title>
**Ticket**: <work item ID> (if applicable, otherwise omit)

### Finding Resolutions

#### Original finding 1 (step N) -- Addressed

<What changed in the revised plan. Why the revision resolves the concern.>

#### Original finding 2 (step N) -- Partially addressed

<What improved. What's still missing or incomplete.>

#### Original finding 3 (step N) -- Not addressed

<The step is unchanged or the concern is still present. Restate the
original reasoning.>

#### Original finding 4 (step N) -- Disputed

<The author's argument. Whether the argument is accepted or rejected,
and why.>

### New Findings

#### F1 [Blocking] Step N

<What the problem is in the added or changed step. Why it matters.
The concrete alternative.>

#### F2 [Suggestion] Step N

<What the problem is. Why it matters. The concrete alternative.>

### Summary

**Resolutions**: N addressed, N partially addressed, N not addressed, N disputed
**New findings**: N blocking, N suggestions, N nits
**Verdict indicator**: request-changes / comment-only / clean
**Next**: `/triage-finding-g` → `/draft-review-g` → `/submit-review-g`
```

##### Template rules -- Plan follow-up

- **Finding resolution headings** reference the original finding by its description and the plan step it targeted.
- **Assessment** is one of `Addressed` (revision resolves the concern), `Partially addressed` (progress but not fully resolved), `Not addressed` (unchanged or concern still present), or `Disputed` (author argues against the finding -- evaluate and accept or reject).
- **New finding headings** use the `F<n>` format with the step reference instead of a file/line.
- **Verdict indicator**: `request-changes` when any new finding is Blocking or any resolution is Not addressed/Partially addressed, `comment-only` when all new findings are non-blocking and all resolutions are Addressed or acceptably Disputed, `clean` when there are zero new findings and all resolutions are Addressed.

This output becomes the input for `/triage-finding-g` (if the user has manual notes) or `/draft-review-g` (if not).

### 8. Evolve

Follow the **capture-improvement-g** skill.
