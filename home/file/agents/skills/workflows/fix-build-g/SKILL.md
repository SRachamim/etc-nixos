---
name: fix-build-g
description: Triage a CI/pipeline failure and fix it in one shot -- diagnoses the failure, classifies it, then either fixes locally, requests a bypass, or files a bug. Use when a build fails and the user wants it resolved without manually triaging then debugging.
---

# Fix Build

Triage a CI/pipeline failure and resolve it in a single invocation. Internally routes to the appropriate action based on failure classification.

## Input

The user specifies (or the agent infers):
- **Build ID or PR**: which build failed (or infer from current branch's latest build)

## Steps

### 1. Triage the failure

Invoke `/triage-build-g` internally.
- Fetch build logs, test results
- Correlate with recent changes
- Classify the failure

### 2. Route based on classification

| Classification | Action |
|---------------|--------|
| **Own code bug** | Proceed to step 3 (fix locally) |
| **Flaky/intermittent test** | Proceed to step 4 (bypass request) |
| **External/infrastructure** | Proceed to step 5 (file bug) |
| **Merge conflict** | Inform user, suggest rebase |

Present the classification and proposed action. **Human gate**: "Failure classified as [type]. Proposed action: [action]. Proceed?"

### 3. Fix locally (own code bug)

Invoke `/debug-g` scoped to the failing test/build step.
- Root-cause the failure
- Design minimal fix

**Human gate**: Present fix approach. On approval:
- Implement the fix
- Invoke `/commit-and-push-g` to push
- Verify the build passes (check pipeline status)

If build still fails after fix, inform the user and offer to iterate.

### 4. Request bypass (flaky test)

Invoke `/submit-bypass-request-g`.
- Posts to `#pipeline-gated` with evidence of flakiness
- Links the failing test's history

### 5. File bug (external issue)

Invoke `/create-bug-g` with:
- Failure evidence from triage
- Affected component/team based on the failing area
- Link to the build

Inform the user the bug is filed and suggest re-running the build later or waiting for the fix.

### 6. Evolve

Follow the **continuous-improvement-g** skill.
