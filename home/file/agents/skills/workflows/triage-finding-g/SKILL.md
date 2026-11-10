---
name: triage-finding-g
description: "Given a single user-authored note, evaluate it against the agent's raw findings from the preceding review and classify it as skip, merge, or add. Reviewing someone else's PR (/review-pr-g, /review-pr-fixes-g): classification only, for /draft-review-g. Refining your own draft (/refine-draft-pr-g): the note also yields feature fixes to apply, and agent improvements traced to the artifact that led the agent to the defect. Invoked per note -- the user queues one call per observation while the agent reviews. Use after /review-pr-g or /review-pr-fixes-g, or during /refine-draft-pr-g."
disable-model-invocation: true
---

# Triage Finding

Given a single user-authored note (passed as the invocation argument), evaluate it against the agent's raw findings from the preceding review, and decide: skip, merge, or add. On the user's own draft, also find out why the agent wrote the defect, so the agent can be fixed along with the code.

The user queues `/triage-finding-g` invocations while the agent reviews. Each invocation is processed in order after the review finishes, building up the consolidated lists the pipeline reads next.

## Modes

Step 1 detects the mode from the pipeline in the conversation:

| Mode | Pipeline | Steps | Outputs | Next reader |
|------|----------|-------|---------|-------------|
| **Reviewing** -- someone else's PR | `/review-pr-g` or `/review-pr-fixes-g` | 1--3, 5--7 | `F<n>` findings, posted later as review comments | `/draft-review-g` |
| **Authoring** -- the user's own draft | `/refine-draft-pr-g` | 1--7 | **Feature fixes** (`F<n>`, one or more per note): fixed up into the feature commit each belongs to. **Agent improvements** (`L<n>` lessons, zero or more per note): a refactoring commit placed **before** the feature commits (workspace artifact), or an observation file (user-level `-g` artifact) | `/refine-draft-pr-g` steps 3--6 |

In authoring mode, the commit order follows preparatory refactoring ("make the change easy, then make the easy change"). The PR reader sees the corrected instruction first, then the feature written under it. Feature fixes and agent improvements stay separate from start to finish: never in the same commit.

## Input

The user's observation as free text. May include a file path, line reference, or just a prose description of the issue.

## Steps

### 1. Validate context and detect the mode

Find the most recent review pipeline run in the conversation:

- `/refine-draft-pr-g` → **authoring**.
- `/review-pr-g` or `/review-pr-fixes-g` → **reviewing**.
- Both in play, with no clear most recent run → ask the user which one the note belongs to.

Then:

- **Review still in progress** (e.g. reviewer subagents running): queue the note. Acknowledge it in one line and gather evidence quietly, without a provisional decision. Once the raw review is presented, process every queued note in order (skip, merge, or add with an `F<n>` ID) in the same response as the raw review. In authoring mode, do this before `/refine-draft-pr-g` step 3.
- **Authoring, verdict tables already approved** (`/refine-draft-pr-g` step 5 or later): tell the user to run `/refine-draft-pr-g` again for another pass, and stop.
- **No review started**: tell the user and stop. Name the matching command: `/refine-draft-pr-g` when the current branch is the user's own draft, otherwise `/review-pr-g`.

### 2. Parse the note

Extract the user's observation:

- **File path** -- if the note mentions a specific file.
- **Line range** -- if the note references specific lines.
- **Concern** -- the issue being raised, in the user's words.

If the note is too vague to act on (no file, no line, no identifiable concern), ask the user to clarify and stop.

### 3. Match against existing findings

Search the agent's raw findings (and any findings added by previous `/triage-finding-g` invocations in the same conversation) for semantic overlap -- same file/line area, same concern. Classify:

- **Skip** -- The note duplicates an existing finding or isn't actionable. State which finding it duplicates and why.
- **Merge** -- The note adds context, evidence, or a better framing to an existing finding. Show the enriched finding with the user's addition integrated.
- **Add** -- The note identifies a genuine issue the agent missed. Create a new raw finding (file, line, severity, description) from the note.

In authoring mode:

- When a note points at several places (for example, the same mistake in three files), create one `F<n>` per place, so each gets its own verdict and fixup.
- Tag every merged or added finding `Source: author note`.

### 4. Trace the cause (authoring only)

Skip in reviewing mode.

For each merged or added `F<n>`, find out why the agent that wrote the code produced the defect: an instruction that misled it, or a rule it needed and didn't have. Read the artifacts that apply to the touched files:

- Workspace: the repo's `AGENTS.md`, `.claude/rules/`, `.cursor/rules/`, and repo-level skills (no `-g` suffix).
- User-level: the `-g` skills that governed the implementation (e.g. **plan-g**, **functional-typescript-g**, **test-driven-development-g**).

Record one outcome per finding:

- **Workspace lesson** -- a minimal before/after diff to one or more workspace artifacts.
- **User-level lesson** -- an observation in the **capture-improvement-g** Path 1 format.
- **No lesson** -- a one-off slip that no artifact caused or could have prevented. The code fix stands alone.

Rules:

- **Evidence only.** Cite the misleading line, or name the specific gap: what the artifact covers and what this defect falls outside of. If you can't point to either, record **No lesson**.
- **One lesson per cause.** Findings that share a cause share one `L<n>`. If a lesson from an earlier note already covers the cause, extend it and link the new finding to it. Don't create a duplicate.
- **Smallest change.** Prefer widening an existing rule to adding a new one, and a scoped workspace rule to a repo-wide one.
- **Mechanical enforcement.** Apply the **tooling-enforcement-g** skill. If a lint rule, type check or hook could catch the defect, put that change in the lesson, alongside or in place of the prose instruction.

This step asks why the defect was **written**. Why the review didn't **catch** it is a separate question, which **codify-review-miss-g** answers later in the pipeline.

### 5. Present the decision

Show the classification and its rationale. Reference findings by their `F<n>` identifier from the raw review output:

- **Skip**: "Skipped -- duplicates F2 (same concern about X in `file.ts:42`)."
- **Merge**: "Merged into F2 -- added your observation about Y." Show the enriched finding.
- **Add**: "Added as new finding -- F<next> [Severity] `file.ts:42-48`: description." Show the new raw finding using the next available `F<n>` number.

In authoring mode, label that list **Feature fixes**, and add an **Agent improvements** list:

- "L2 (workspace) `.claude/rules/foo.md`: <one-line change> -- explains F7, F8." Show the before/after diff.
- "L3 (user-level) `functional-typescript-g`: <one-line change> -- explains F9." Show the observation's suggested change.
- "None -- F7 is a one-off slip: <reason>."

The user can override any decision in a follow-up message.

### 6. Update the running lists

Apply the decisions to the conversation's running findings list: new findings receive the next sequential `F<n>` identifier. In authoring mode, also update the lessons list: new lessons receive the next sequential `L<n>`, each linked to the findings it explains.

The next `/triage-finding-g` invocation reads the updated lists, then `/draft-review-g` (reviewing) or `/refine-draft-pr-g` steps 3--6 (authoring).

### 7. Evolve

Follow the **capture-improvement-g** skill, focused on this triage call. Every call runs inside a parent workflow (`/submit-review-g` at the end of the review pipeline, or `/refine-draft-pr-g`) whose own Evolve step reflects on the whole thread, so defer to it: run the reflection once there, not once per note.
