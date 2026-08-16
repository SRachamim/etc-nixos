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

### 3a. Pre-commit gap retrospective

After fixing an "own code bug" failure, investigate why the pre-commit hook did not catch it:

1. **Identify the check**: What CI step failed? (test name, lint rule, type error, build step)
2. **Check pre-commit coverage**: Does the pre-commit hook run this check? Inspect `.husky/`, `lint-staged` config, or equivalent.
3. **Classify the gap**:

| Gap type | Meaning | Action |
|----------|---------|--------|
| **Hook doesn't cover** | Pre-commit hook doesn't run this check at all | Propose extending the hook -- apply **tooling-enforcement-g** |
| **Hook was bypassed** | Agent used `--no-verify` or equivalent | Fix the workflow skill that bypassed it -- apply **continuous-improvement-g** |
| **Scope mismatch** | Hook runs the check but only on staged files; CI runs the full suite and catches cross-file breakage | Propose a broader local check (e.g. `pnpm test` on affected packages, not just staged files) |
| **Environment parity** | CI has dependencies, services, or config unavailable locally | Document as a known CI-only gate (no local prevention possible) |
| **Non-deterministic** | Flaky test, timing issue, or platform difference | Route to Step 4 (bypass request) instead |

4. **Propose prevention**: Based on the gap type, present one concrete action to close the gap. The action targets project tooling (pre-commit hook, CI config) or agent artifacts (workflow skills), not both.

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
