---
name: deliver-feature-g
description: End-to-end feature delivery in a single command -- checks out worktree, plans, implements, drafts and refines the PR, submits it, and queues cleanup. Use when the user wants to deliver a work item from start to finish. Supports both ticket-based and PRD-based flows.
---

# Deliver Feature

Orchestrate the full feature delivery lifecycle from a single invocation. Runs autonomously with exactly two human gates -- plan approval and implementation approval. All intermediate decisions are made without user input.

## Input

- **Work item ID**: the ADO work item to deliver (required)
- **--prd**: if specified, route through PRD intake before planning

## Autonomy contract

This workflow pauses for user input at exactly **two** points:

1. **Gate 1 -- Plan approval**: after the plan is materialized, the user reviews, iterates, or approves.
2. **Gate 2 -- Implementation approval**: after all commits are made, verified, and opened as a draft PR, the user reviews the implementation diff and the draft-review verdict table, iterates, or approves.

Outside these gates, the agent proceeds autonomously. Specifically:

- Do **not** ask clarifying questions -- infer all context from the work item.
- Do **not** request confirmation of understanding.
- Do **not** present intermediate artifacts (Slack messages, work item transitions) for separate approval.
- Do **not** offer the user choices when encountering obstacles -- attempt autonomous resolution first.

When delegating to sub-skills, override their interactive behaviour to honour this contract. Any approval gates defined inside delegated skills (e.g. Slack message approvals in **submit-feature-g**) are skipped -- compose and execute automatically after Gate 2. The same applies to the PR title and description approval in **create-pr-g** (reached through **draft-feature-g** and **submit-feature-g**), the verdict-table approval in **refine-draft-pr-g** (folded into Gate 2), and the `--force-with-lease` confirmation in **commit-and-push-g** fixup mode (the draft has no reviewers yet).

## Steps

### 1. Checkout worktree

Follow the **checkout-worktree-g** skill with the work item ID.
- Creates isolated worktree and feature branch.
- Activates the work item (state -> Active).
- Opens the worktree in a workmux tmux window (last step of **checkout-worktree-g**); this session continues the delivery.

### 2. Plan

Switch to **Plan** mode following the **mode-gate-g** skill. The planning phase is read-only analysis -- Plan mode keeps the focus on design rather than premature edits.

**If `--prd` specified:**
- Follow the **analyze-prd-g** skill autonomously (do not iterate with the user -- produce the structured analysis in one pass).
- Then follow the **plan-from-prd-intake-g** skill with the intake output.

**Otherwise:**
- Follow the **plan-g** skill in **orchestrated mode** -- do not ask clarifying questions, infer all context from the work item. The skill will explore the codebase, draft a commit-by-commit plan, and materialize it via the plan-creation tool (e.g. Cursor's `CreatePlan`). If no plan-creation tool is available, the plan is output as markdown in the thread.

**Gate 1 -- Plan approval**: execution pauses here. The user reviews the materialized plan, can edit it inline, iterate via follow-up messages, or approve. To proceed, the user switches back to Agent mode (or clicks "Build" in Cursor).

### 3. Implement

Once the user approves the plan and switches to Agent mode, execution proceeds automatically per the approved plan (internally uses **plan-execution-g**).

Each commit is made as the plan dictates. Build and tests are verified after each commit.

If implementation hits an unexpected obstacle, attempt to resolve it autonomously:
- Adapt the approach to work around the issue.
- Fix failing tests or compilation errors.
- Only inform the user if the obstacle cannot be resolved after reasonable attempts. This is an exception, not an approval gate.

### 3.5. Verify

Apply the **verification-strategy-g** skill's execution protocol.
Run all Level 5-6 verification artifacts added during implementation:

- Discover the run commands via the skill's discovery protocol.
- Execute only the new/modified E2E test files -- not the full suite.
- If any test fails: fix the implementation, commit the fix, re-run.
- If a test cannot run locally: document in the PR description with risk acknowledgment.

This step ensures the feature works end-to-end before human review begins.
Levels 1-4 are already covered per-commit by **plan-execution-g**'s validation step.

### 4. Draft and review

Before Gate 2, open a draft PR and get a clean-context review of the whole change:

1. Follow the **draft-feature-g** skill with the work item ID. It commits any leftover changes, pushes, and opens a draft PR linked to the work item, without a state transition or Slack messages.
2. Follow the **refine-draft-pr-g** skill, steps 1--4, on that draft. Skip its step 0 mode gate: steps 1--4 are read-only by instruction. Its review runs **review-pr-g** in a clean-context subagent, which spawns the **reviewer** subagent (plus **quality-reviewer** for fgrepo changes under `client/`), and falls back to an inline review when subagents are unavailable.

**Gate 2 -- Implementation approval**: present in one message the full implementation diff (`git diff <default-branch>...HEAD`), a summary of all commits made, and the verdict table from **refine-draft-pr-g** step 4. The user approves, overrides verdicts, or requests implementation changes.

If the user requests changes, apply them, re-verify, follow the **commit-and-push-g** skill in **commit** mode so the draft matches `origin`, and present the updated diff. Re-run **refine-draft-pr-g** steps 2--4 only when the user asks. Repeat until approved.

If the review is `clean`, skip step 5.

### 5. Apply review fixes

After Gate 2 approval, follow the **refine-draft-pr-g** skill, steps 5--6: fix the approved **Agree-fix** and **Partial** findings, apply **self-review-g**, run the checks, and fold the fixes into the draft's commits with **commit-and-push-g** in **fixup** mode, force-pushing without asking. Keep the **Agree-defer** and **Need-context** findings for the completion summary.

### 6. Submit PR

Follow the **submit-feature-g** skill. Override its interactive behaviour per the autonomy contract:

- Compose the PR description and select reviewers automatically. **create-pr-g** publishes the existing draft with auto-complete set instead of creating a new PR.
- Transition the work item to Code Review automatically.
- Compose and send the Slack notification automatically -- do not present it for separate approval.
- Agent artifact and automation folder notifications (fgrepo only) are sent automatically.

Do not improvise PR submission -- the skill encodes the correct Slack channels, artifact notification recipients, and formatting conventions.

### 7. Completion

Print a summary of everything done:
- PR link, noting it was published from draft with auto-complete set.
- Draft-review outcome: counts of fixed, deferred, rejected and open findings, listing the deferred and open ones.
- Work item link and new state.
- Slack notification confirmation.
- Reminder: "Run `/close-worktree-g` after the PR merges."

### 8. Evolve

Follow the **capture-improvement-g** skill.
