---
name: deliver-feature-g
description: End-to-end feature delivery in a single command -- checks out worktree, plans, implements, submits PR, and queues cleanup. Use when the user wants to deliver a work item from start to finish. Supports both ticket-based and PRD-based flows.
---

# Deliver Feature

Orchestrate the full feature delivery lifecycle from a single invocation. Internally delegates to existing skills with human gates at plan approval and PR submission only.

## Input

- **Work item ID**: the ADO work item to deliver (required)
- **--prd**: if specified, route through PRD intake before planning

## Steps

### 1. Checkout worktree

Follow the **checkout-worktree-g** skill with the work item ID.
- Creates isolated worktree and feature branch
- Activates the work item (state -> Active)

### 2. Plan

**If `--prd` specified:**
- Follow the **analyze-prd-g** skill -- iterate with the user until structured analysis is produced
- Then follow the **plan-from-prd-intake-g** skill with the intake output

**Otherwise:**
- Follow the **plan-g** skill -- explore codebase, draft commit-by-commit plan

**Human gate**: Present the plan. Ask: "Approve this plan?"

If the user requests changes, iterate on the plan before proceeding.

### 3. Implement

Execution proceeds automatically per the approved plan (internally uses **plan-execution-g**).

Each commit is made as the plan dictates. Build and tests are verified after each commit.

If implementation hits an unexpected obstacle:
- Pause and inform the user
- Offer: revise plan, skip the problematic step, or abort

### 3.5. Verify

Apply the **verification-strategy-g** skill's execution protocol.
Run all Level 5-6 verification artifacts added during implementation:

- Discover the run commands via the skill's discovery protocol
- Execute only the new/modified E2E test files -- not the full suite
- If any test fails: fix the implementation, commit the fix, re-run
- If a test cannot run locally: document in the PR description with risk acknowledgment

This step ensures the feature works end-to-end before human review begins.
Levels 1-4 are already covered per-commit by **plan-execution-g**'s validation step.

### 4. Submit PR

Follow the **submit-feature-g** skill in full.
Do not improvise this step -- the skill encodes the correct Slack channels,
artifact notification recipients, and human gates.

**Human gate**: Confirm PR title, description, and reviewers before posting.

### 5. Queue cleanup

Inform the user: "PR submitted. Run `/close-worktree-g` after it merges, or I can monitor and close automatically."

### 6. Evolve

Follow the **capture-improvement-g** skill.
