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
- When the agent can spawn subagents, step 5 delegates line-level reading. Here, read only what step 4 needs: the commit messages, `git diff --stat origin/<target>...origin/<source>`, and the hunks behind any design question. Otherwise read the whole diff:
  - Read each PR commit individually using `git show <sha>` for a commit-by-commit view.
  - Alternatively, read the full PR diff using `git diff origin/<target>...origin/<source>` when a holistic view is more useful.
  - For each changed file, read surrounding context beyond the diff hunks from the PR revision (`git show origin/<source>:<path>`), not the working tree -- the local checkout may be on a different revision.

### 4. Evaluate design

Skip this step entirely when:

- The PR is trivial -- a single commit touching one module with no restructuring, no design decisions, and no new file, type, or abstraction (script, tool, helper).

Even when the rest of this step is skipped, run **Check for existing solutions** for every new type, interface, or abstraction the PR adds -- one new type is enough to trigger it.
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

When the PR introduces a new abstraction (component, hook, utility, module, service, type, or interface), search the codebase for existing abstractions that address the same problem. Treat as new abstractions too: a styled element that rebuilds a control another component provides, and a style override that reaches into another component's internals (`${Other} button`) -- for an override, ask whether the target component should own a variant. Look for:

- Same domain concept under a different name.
- Same type shape -- for a new type or interface, grep its field names (e.g. `added` + `removed`) across the repository, starting with sibling files.
- Same structural pattern applied to a related use case (e.g. collapsing header vs. collapsing footer).
- Utility functions or hooks that already encapsulate the logic being re-implemented.

If a match exists, evaluate whether the PR should **reuse** the existing abstraction, **compose** with it, or **generalize** it into a shared solution. A new abstraction that reimplements logic already present elsewhere is a design finding (severity: Suggestion or Blocking depending on the degree of duplication). Also consider dropping the requirement that motivated the new code -- a one-line option change can make a new script unnecessary.

#### Research prior art

Apply the **prior-art-research-g** skill to check whether established patterns or approaches exist for the problem domain the PR addresses. Compare the PR's approach against known patterns from the FP, DDD, and software design literature. Note whether the PR aligns with, adapts, or departs from established solutions.

When the PR changes how a third-party library or tool is configured or used (cache policies, framework options, client setup, CLI flags), the library's own docs come first: check whether the change is the documented fix for the diagnosed problem, and confirm the behaviour it relies on in the version the repo pins (lockfile, `node_modules` source).

#### Apply the design lenses

Apply the **design-lenses-g** skill using the **review framing** for all three lenses (refactoring, flexibility, architecture). Apply the **decision-priorities-g** skill to check whether the chosen approach respects the priority ordering (correctness > changeability > DX, governed by simplicity).

#### Gap analysis

- **Missing steps** -- work the PR implies but doesn't include (e.g. a migration, a config change, an export update).
- **Unacknowledged risks** -- breaking changes, performance implications, or edge cases the commits don't account for.

### 5. Evaluate code

When the agent can spawn subagents, delegate the line-level evaluation so the diff stays out of the main context:

- Spawn the **reviewer** subagent with the target and source refs, the commit list, the in-scope file list, and the standards listed below. For more than about 15 files, spawn one reviewer per module or package, each with its own files. The brief must forbid `git checkout`/`git switch` in the workspace -- reviewers read branch files with `git show <source-ref>:<path>` -- and must name the placement sweep explicitly: check every new exported type, function, or constant against the module placement rule in **code-review-g** Convention compliance, including those added to files that predate the PR.
- For fgrepo PRs with changed files under `client/`, also spawn the **quality-reviewer** subagent with an isolation brief as defined by the **client-quality-focus-g** skill.
- Merge the returned findings, drop duplicates, and check each against the diff hunk it cites before carrying it into step 6. Then check each finding's proposed fix:
  - When the fix patches the author's approach, check whether the tool or library has a standard idiom that removes the problem (flag precedence, a built-in option) and propose that instead.
  - When the fix moves or extracts code into another file, check the target against the placement rule (fgrepo client/: the `client-module-anatomy` Function Placement procedure). Drop the suggestion if no valid home exists.

Otherwise, evaluate inline. Either way, the standards are the same: apply the **code-review-g** skill for general review standards.

Additionally:

- Apply the **functional-typescript-g** skill if the PR contains TypeScript files.
- Apply the **commit-conventions-g** skill to evaluate commit structure and hygiene.
- **Load relevant workspace rules**: the target repository may define conditional workspace rules (rules scoped to specific file patterns or content domains) that don't auto-load during review -- the agent reads diffs via git commands rather than opening files through the editor, so path-based triggers may not fire. Match mechanically, not by recall: for every conditional rule in the scoped domain (e.g. `.cursor/rules/**/*.mdc`), read its `globs` frontmatter, test it against the in-scope changed files, and read every rule that matches before evaluating. Also load rules whose description matches content in the diff (e.g. CSS rules for stylesheet changes, React hook rules for hook changes). Pass the loaded rules to the reviewer subagents and list them in the raw review header. Always-applied rules are already in context.
- **fgrepo client/ quality gate**: When the PR belongs to fgrepo and includes changed files under `client/`, read the repo-level `client-code-quality-gate` skill (`client/.agents/skills/client-code-quality-gate/SKILL.md`) and apply its verification checks (Sections A--C) to each changed client/ file during code evaluation. Quality gate checks are conditional on each check's "When to run" trigger -- skip checks whose trigger does not apply. Map quality gate severity to review findings: `blocking` items become blocking review findings, `warning` items become suggestions. A single check can bundle sub-conditions of different gravity -- map on the sub-condition that actually failed, not the check's headline severity. When the mapped severity differs from the headline, state the deviation and its reasoning in the finding so the severity is reproducible. This loading is mandatory -- do not rely on path-based auto-discovery.

### 6. Present raw findings

Output the review results directly in the conversation using the structured template below. Do not use `CreatePlan`, plan tools, or external documents -- the output must be inline markdown in the chat so downstream skills (`/triage-finding-g`, `/draft-review-g`) can read it from conversation context.

Use a lightweight internal format -- no **delivered-text-g** composition, no fenced code blocks of literal post text.

#### Output template

```
## Raw Review: [PR #<id>](<ADO PR URL>)

**Repository**: <name> (repo ID: <id>)
**Branches**: `<source>` → `<target>`
**Commits**: <count> (<first-sha>..<last-sha>)
**Changed files**: <count>
**Slack-originated**: yes (channel: <id>, ts: <ts>) / no
**Rules loaded**: <conditional rules matched in step 5, or "none">

### Design Evaluation

> Present only when step 4 applied. Omit this entire section for trivial PRs.

**Goal**: <reconstructed goal from the commit sequence>
**Target state**: <what the codebase should look like after the PR lands>
**Commit strategy**: <ordering assessment -- refactorings separated? tests first?>
**Design decisions**: <what was chosen and what was implicitly rejected>

Design findings (if any):
- <design-level concerns, gap analysis results, prior-art observations>

### Findings

#### F1 [Blocking] `src/path/to/file.ts` L42-48

<What the problem is. Why it matters. The concrete alternative --
how to solve it differently.>

#### F2 [Suggestion] `src/path/to/other.ts` L15

<What the problem is. Why it matters. The concrete alternative.>

#### F3 [Nit] `src/path/to/another.ts` L100-105

<What the problem is. The concrete alternative.>

### Summary

| Severity | Count |
|----------|-------|
| Blocking | N |
| Suggestion | N |
| Nit | N |

**Verdict indicator**: request-changes / comment-only / clean
**Next**: `/triage-finding-g` (if you have manual notes) → `/draft-review-g` → `/submit-review-g`
```

#### Template rules

- **PR link** in the `## Raw Review` heading must be a clickable markdown link to the ADO PR page. This is the first thing the user sees -- it lets them open the PR in parallel while reading the review output.
- **Finding headings** use the format `#### F<n> [Severity] \`file/path\` L<start>-<end>` (or `L<line>` for single-line findings). The range must be postable as-is by `/submit-review-g`: the file is in the PR diff, and both `<start>` and `<end>` are non-blank lines in the source-branch file (a blank line yields an empty selection in ADO -- move to the nearest non-blank line in the hunk). When the issue lives in a file outside the diff, anchor on the in-diff line that causes or mirrors it and name the outside file in the body. The `F<n>` identifier is stable -- `/triage-finding-g` references findings by this ID.
- **Severity** is one of `Blocking`, `Suggestion`, or `Nit` per the **code-review-g** skill.
- **Issue description** (the body under each finding heading) must include: what the problem is, why it matters, and the concrete alternative. This is the raw judgment -- `/draft-review-g` transforms it into delivered text.
- **Design Evaluation** section appears only when step 4 ran. When omitted, the `### Findings` section follows directly after the header.
- **Verdict indicator**: `request-changes` when any finding is Blocking, `comment-only` when all findings are Suggestion or Nit, `clean` when there are zero findings.
- **Verification**: count listed findings against issues identified in steps 4--5. If any issue lacks a corresponding `F<n>` entry, add it now.

This output becomes the input for `/triage-finding-g` (if the user has manual notes) or `/draft-review-g` (if not).

### 7. Evolve

Follow the **capture-improvement-g** skill.
