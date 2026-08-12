---
name: fix-bug-g
description: End-to-end bug resolution in a single command -- checks out worktree, reproduces, debugs, fixes, submits PR, and cleans up. Use when the user wants to fix a bug from start to finish without invoking each step manually.
---

# Fix Bug

Orchestrate the full bug resolution lifecycle from a single invocation. Internally delegates to existing skills with human gates at key decision points only.

## Input

- **Work item ID**: the ADO Bug to fix (required)
- **Skip reproduction**: if the bug is well-understood, pass `--skip-repro` to go straight to debug

## Steps

### 1. Checkout worktree

Invoke `/checkout-worktree-g` with the work item ID.
- Creates isolated worktree and feature branch
- Activates the work item (state -> Active)

### 2. Reproduce the bug

Unless `--skip-repro` was specified:

Invoke `/reproduce-bug-g`.
- Launches local dev stack
- Verifies the defect via browser/API
- May need `/set-igw-g` and `/set-ports-g` if environment isn't configured

**Human gate**: Present reproduction evidence. Ask: "Bug reproduced. Proceed to debug?"

If reproduction fails, inform the user and stop (they may need to refine repro steps or environment setup).

### 3. Debug and fix

Invoke `/debug-g`.
- Root-cause investigation (Five Whys)
- Designs a TDD fix (regression test first)

**Human gate**: Present the fix plan (which files change, what the test covers). Ask: "Approve fix approach?"

On approval, implements the fix.

### 4. Submit PR

Invoke `/submit-feature-g`.
- Opens PR with proper description linking the bug
- Transitions work item to Code Review
- Posts to Slack

**Human gate**: Confirm PR details before posting.

### 5. Queue cleanup

Inform the user: "PR submitted. Run `/close-worktree-g` after it merges, or I can monitor and close automatically."

If the user confirms auto-close, note the PR ID for later `/close-worktree-g` invocation.

### 6. Evolve

Follow the **continuous-improvement-g** skill.
