---
name: codify-review-miss-g
description: "Analyzes non-skipped /triage-finding-g decisions (merge and add) to identify blind spots in review skills, then persists targeted improvement observations. Called by submit-review-g after the review is posted -- requires the full review pipeline conversation context."
disable-model-invocation: true
---

# Codify Review Miss

Turn non-skipped `/triage-finding-g` decisions into targeted improvements for the review skill ecosystem. Every "merge" or "add" triage decision is evidence that the agent's review skills have a blind spot -- this skill analyzes the miss, root-causes it, and persists an improvement observation.

This is a shared skill called by **submit-review-g** (step 8). It requires the full conversation context of the review pipeline: the raw review output, the triage decisions, and the PR diff.

## Input

No arguments. The skill reads non-skipped triage decisions from the conversation context.

## Skip condition

If the conversation contains no `/triage-finding-g` invocations with "merge" or "add" decisions, this skill is a no-op -- produce no output and return immediately.

## Steps

### 1. Collect non-skipped triage findings

Scan the conversation for all `/triage-finding-g` invocations. For each, extract:

- **Triage decision**: "merge" or "add" (skip decisions are ignored).
- **The user's original observation**: the free-text note the user provided.
- **The finding details**: file path, line range, concern description, severity.
- **For "merge" decisions**: the original agent finding (`F<n>`) that was enriched and what the user added.
- **For "add" decisions**: the new finding (`F<n>`) that was created from the user's observation.

If no non-skipped triage findings exist, stop (see skip condition above).

### 2. Classify each miss

For each non-skipped triage finding, map it to a **code-review-g** evaluation dimension. Record the dimension and triage type weight for each finding -- these appear in the per-finding template in step 5.

| Dimension | What it covers |
|-----------|---------------|
| Behavioral effect | Change doesn't achieve its claimed goal |
| Correctness | Bugs, unhandled edge cases, uncovered error paths |
| Security | Input validation, secrets, injection risks |
| Design | Abstraction level, responsibility separation, existing pattern reuse |
| Architecture | Component boundaries, dependency directions, coupling |
| Test coverage | Missing tests for new behaviors, edge cases, error paths |
| Performance | Inefficiencies, unnecessary allocations, N+1 patterns |
| Flexibility | Additive design, Postel's law, combinator patterns |
| Clarity | Intent legibility, naming, unnecessary complexity |
| Convention compliance | Workspace rules, project standards |

If the finding doesn't fit any existing dimension, record "new dimension needed" -- this is itself a signal that `code-review-g` has a gap.

Also classify the **triage type weight**:

- **"Add" findings** (agent missed entirely): strongest signal. The agent had no finding for this issue -- likely a dimension gap or step gap.
- **"Merge" findings** (agent found something nearby but the user enriched it): weaker signal. The agent was in the neighborhood but lacked depth or precision -- likely an accuracy improvement to an existing dimension or step.

### 3. Root-cause the miss

For each non-skipped triage finding, determine *why* the agent didn't catch it. Record the root-cause classification and one-sentence reasoning for each finding -- these appear in the per-finding template in step 5. Classify into one of three root causes:

- **Dimension gap**: the evaluation dimension exists in **code-review-g** but its description is too narrow to cover this pattern. The dimension text doesn't prompt the agent to look for this class of issue.
  - *Target artifact*: `code-review-g` -- expand the dimension description.

- **Step gap**: `review-pr-g` or `review-pr-fixes-g` doesn't have a step that would trigger evaluation of this pattern. The workflow doesn't direct the agent to perform the analysis that would have caught this.
  - *Target artifact*: `review-pr-g` or `review-pr-fixes-g` -- add or expand an evaluation step.

- **Context gap**: the agent had insufficient context to catch the issue. It didn't read the right files, didn't load the right workspace rules, or didn't examine surrounding code beyond the diff hunks.
  - *Target artifact*: `review-pr-g` or `review-pr-fixes-g` -- expand the context-gathering step (step 2 or step 3).

When the root cause is ambiguous, prefer the explanation that requires the smallest change -- a narrow dimension expansion over a new workflow step, a step expansion over a new step.

### 4. Determine enforcement tier

For each miss, classify whether the correction can be enforced deterministically or requires semantic judgment. Record the enforcement tier for each finding -- these appear in the per-finding template in step 5. Apply the **tooling-enforcement-g** skill.

- **Deterministic**: the issue could be caught by a lint rule, type check, or pre-commit hook (e.g., "always check that async operations have cleanup in useEffect"). If yes, recommend promoting to the tooling stack *and* adding a behavioral rule for the semantic aspect that the tool can't cover. The two compose.

- **Semantic**: the correction requires judgment -- design patterns, architectural alignment, context-dependent trade-offs (e.g., "check whether a new abstraction duplicates an existing one"). Propose a behavioral rule addition to the target skill.

Record the tier for each miss. The observation file will include both the skill improvement and the tooling recommendation (if applicable).

### 5. Propose specific edits

For each miss, present a structured proposal using the template below. Every field is required -- do not skip or collapse findings into a summary.

**Finding F\<n\>: \<one-line description\>**

| Field | Value |
|-------|-------|
| Triage type | add / merge |
| Dimension | \<from step 2\> |
| Root cause | \<dimension-gap / step-gap / context-gap\> -- \<one sentence reasoning from step 3\> |
| Enforcement tier | \<deterministic / semantic\> -- \<from step 4\> |
| Target artifact | \<file path\> |
| Category | \<accuracy / missing-step / new-field\> |
| Confidence | \<high / medium / low\> |

**What the agent missed**: \<one sentence\>

**Why this matters**: \<one sentence -- consequence if not fixed\>

**Proposed change**:

```diff
- <before>
+ <after>
```

---

Group findings by target artifact for readability. Present all proposals to the user for approval before persisting.

### 6. Persist approved observations

For each approved proposal, classify the target artifact's scope using **capture-improvement-g** routing logic, then act accordingly.

#### Path 1 -- user-level (`-g`) skill

The target artifact name ends with `-g` and its source lives in the dotfiles repo (e.g., `code-review-g`, `review-pr-g`, `review-pr-fixes-g`). Write a structured observation file to `~/.local/share/agent-improvements/pending/`.

Observation file format:

```yaml
---
source-skill: codify-review-miss-g
observed-during: <review-pr-g or review-pr-fixes-g>
affected-artifact: <path-relative-to-dotfiles-repo>
category: <accuracy|missing-step|new-field>
confidence: <high|medium|low>
observed-at: <ISO-8601-timestamp>
workspace: <absolute-path-to-current-workspace>
triage-type: <add|merge>
review-dimension: <dimension from step 2>
root-cause: <dimension-gap|step-gap|context-gap>
enforcement-tier: <deterministic|semantic>
---
```

Followed by:

```markdown
## What happened

<one sentence: what the agent missed during the review>

## Why this matters

<one sentence: this class of issue will recur in future reviews>

## Root cause

<root-cause classification and reasoning from step 3>

## Suggested change

<before/after diff from step 5>

## Tooling recommendation

<deterministic enforcement recommendation from step 4, or "None -- semantic judgment required">
```

Filename: `{ISO-timestamp}_{category}_{affected-skill-name}.md`

#### Path 2 -- workspace-level artifact

The target artifact lives in the current workspace (e.g., a repo-level quality gate skill, a workspace rule, a repo-level `.cursor/rules/` or `.claude/rules/` file). Apply the edit as a separate commit following **capture-improvement-g** Path 2 mechanics -- the commit message body must explain what was missed during the review and why the fix prevents recurrence.

#### Path 3 -- workspace-level artifact, others' code

The target artifact lives in the current workspace but the user is reviewing someone else's PR (not their own branch). Do NOT commit to the reviewed branch. Instead, present the finding and ask whether to create a Task work item to track the fix, following **capture-improvement-g** Path 3 mechanics.

#### Scope determination

Use the same heuristic as **capture-improvement-g**: check if the artifact name ends with `-g` and lives outside the current workspace (Path 1), check if it exists in the current workspace on the user's own branch (Path 2), or check if it's in the workspace but the user is reviewing others' code (Path 3). When in doubt, present the classification and ask.

Also present each observation in the conversation so the user sees what was persisted or committed.

## Confidence scoring

Assign confidence based on the strength of the signal:

| Signal | Confidence |
|--------|-----------|
| "Add" finding with clear dimension gap | high |
| "Add" finding with ambiguous root cause | medium |
| "Merge" finding that significantly enriched the original | medium |
| "Merge" finding that added minor context | low |

Low-confidence observations are still persisted -- the consuming skill (`review-retrospective-g`) can use frequency across multiple reviews to elevate low-confidence individual observations into high-confidence patterns.

## Constraints

- **No summary-only output** -- a prose summary of triage findings is not valid output for this skill. Every non-skipped finding MUST produce a per-finding analysis (steps 2-4) and a concrete before/after diff proposal (step 5) presented to the user for approval. If you find yourself writing "these are patterns to watch for in future reviews," you have not executed this skill.
- **Evidence-based only** -- every proposal traces back to a specific triage finding from the current review. Do not speculate about other potential improvements.
- **Minimal diff** -- change only what is needed in the target artifact. Do not reformat or restructure surrounding content.
- **User approval required** -- never persist an observation without user approval.
- **One observation per miss** -- each non-skipped triage finding produces at most one observation targeting the most impactful artifact. Do not propose the same improvement to multiple artifacts.
- **Route correctly** -- user-level (`-g`) skills produce observation files (Path 1); workspace-level artifacts on the user's own branch produce commits (Path 2); workspace-level artifacts on others' code produce task proposals (Path 3). Follow the **capture-improvement-g** routing heuristic.
