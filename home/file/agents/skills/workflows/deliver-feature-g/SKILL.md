---
name: deliver-feature-g
description: End-to-end feature delivery in a single command -- checks out worktree, plans, implements, submits PR, and queues cleanup. Use when the user wants to deliver a work item from start to finish. Supports both ticket-based and PRD-based flows.
---

# Deliver Feature

Orchestrate the full feature delivery lifecycle from a single invocation. Runs autonomously with exactly two human gates -- plan approval and implementation approval. All intermediate decisions are made without user input.

## Input

- **Work item ID**: the ADO work item to deliver (required)
- **--prd**: if specified, route through PRD intake before planning

## Autonomy contract

This workflow pauses for user input at exactly **two** points:

1. **Gate 1 -- Plan approval**: after the plan is materialized, the user reviews, iterates, or approves.
2. **Gate 2 -- Implementation approval**: after all commits are made and verified, the user reviews the implementation diff, iterates, or approves.

Outside these gates, the agent proceeds autonomously. Specifically:

- Do **not** ask clarifying questions -- infer all context from the work item.
- Do **not** request confirmation of understanding.
- Do **not** present intermediate artifacts (Slack messages, work item transitions) for separate approval.
- Do **not** offer the user choices when encountering obstacles -- attempt autonomous resolution first.

When delegating to sub-skills, override their interactive behaviour to honour this contract. Any approval gates defined inside delegated skills (e.g. Slack message approvals in **submit-feature-g**) are skipped -- compose and execute automatically after Gate 2.

## Steps

### 1. Checkout worktree

Follow the **checkout-worktree-g** skill with the work item ID.
- Creates isolated worktree and feature branch.
- Activates the work item (state -> Active).

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

### 4. Review implementation

**Gate 2 -- Implementation approval**: present the full implementation diff (`git diff <default-branch>...HEAD`) and a summary of all commits made. The user reviews the implementation, can request changes, or approves.

If the user requests changes, apply them, re-verify, and present the updated diff. Repeat until approved.

### 5. Submit PR

After Gate 2 approval, follow the **submit-feature-g** skill. Override its interactive behaviour per the autonomy contract:

- Compose the PR description, select reviewers, and create the PR automatically.
- Transition the work item to Code Review automatically.
- Compose and send the Slack notification automatically -- do not present it for separate approval.
- Agent artifact and automation folder notifications (fgrepo only) are sent automatically.

Do not improvise PR submission -- the skill encodes the correct Slack channels, artifact notification recipients, and formatting conventions.

### 6. Completion

Print a summary of everything done:
- PR link.
- Work item link and new state.
- Slack notification confirmation.
- Reminder: "Run `/close-worktree-g` after the PR merges."

### 7. Evolve

Follow the **capture-improvement-g** skill.
