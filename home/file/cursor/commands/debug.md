# Debug

Given a bug work item (or a description of defective behaviour), investigate the codebase to find the root cause, design a minimal fix, and implement it. The first commit is always a regression test that captures the bug before the fix is applied.

## Input

Accept **any** of the following:

1. **Ticket reference** -- an Azure DevOps work item ID (e.g. `12345`) or full URL. Fetch it via MCP and extract title, type, description, repro steps, severity, acceptance criteria, state, assignee, iteration, children, linked PRs/commits, and comments.
2. **Textual description** -- a plain-language description of the bug (e.g. "the portfolio API returns 500 when account ID contains special characters"). Treat the text as the authoritative specification.

When both a ticket and additional text are provided, the text supplements the ticket -- it does not replace it.

## Steps

### 0. Recommended mode: Debug

Require **Debug** mode following the **mode-gate** skill. This command investigates a bug in the codebase -- Debug mode is the best fit for the investigation phase (steps 1--4).

### 1. Fetch the bug

- **If ticket**: fetch the work item with full details and relations. Extract repro steps, severity, acceptance criteria, child work items, linked PRs/commits, and comments.
- **If text**: restate the defective behaviour in your own words and confirm understanding before proceeding.
- Extract the key facts:
  - **What is broken** -- the observed (incorrect) behaviour.
  - **What should happen** -- the expected (correct) behaviour.
  - **How to trigger it** -- reproduction steps, if available.

### 2. Reproduce the symptoms

Locate the code path that the reproduction steps exercise:

- Search the codebase for the affected area (endpoints, functions, modules).
- Read the relevant code to understand the current implementation.
- Trace the execution path from input to the point where the wrong result is produced.
- If tests exist for the affected code, check whether they cover the failing scenario. If they do and pass, the bug may be in a different layer.

If the bug is visual, UI-driven, or requires interacting with the running application to reproduce, apply the **browser-bug-reproduction** skill to verify the behaviour in the browser before proceeding to root-cause analysis.

Spend enough time here to form a concrete understanding of what the code currently does. Don't guess -- read the code.

### 3. Isolate the root cause

Work from symptoms inward:

1. **Where** -- narrow from service to module to function. Identify the smallest unit of code that produces the wrong result.
2. **Why** -- determine why that code produces the wrong result for the given input. Common categories:
  - Missing case in a discriminated union or conditional.
  - Incorrect transformation or mapping.
  - Boundary condition not handled (empty input, special characters, overflow).
  - Stale assumption about an upstream dependency.
  - Race condition or ordering issue.
3. **Scope** -- assess whether the root cause affects other code paths beyond the reported bug. Note any collateral impact.
4. **Five Whys** -- for each "why" answer, ask "why" again until you reach a root cause that is actionable and structural, not just a proximate trigger. Watch for:
  - Assumptions that were valid when the code was written but no longer hold.
  - Organisational or process causes (e.g., missing test coverage policy, absent monitoring).
  - "Because we always did it this way" -- a signal that the environment has changed around the code.

### 4. Present findings

Present the investigation results to the user:

```
## Bug: <title>

**Source**: <ticket link or "textual description"> | **Severity**: <severity or "n/a"> | **State**: <state or "n/a">

### Symptoms

<What is broken -- the observed behaviour and how to trigger it>

### Root Cause

<Concise explanation: where in the code the fault is, and why it produces the wrong result>

### Affected Code

<List of files and functions involved, with brief explanation of each one's role>

### Collateral Impact

<Other code paths or scenarios affected by the same root cause, if any. "None identified" if the bug is isolated.>
```

Wait for the user to confirm the root-cause analysis before proceeding to fix planning.

### 5. Enter Plan mode

Require **Plan** mode following the **mode-gate** skill. The fix-planning phase (steps 6--8) is read-only design -- Plan mode keeps the focus on discussion rather than edits.

### 6. Design the fix

Design a sequence of commits to fix the bug. The **test-driven-development** skill's Regression Test pattern is mandatory: the first commit must be a failing test that captures the bug.

#### Commit sequence

1. **Regression test** -- write the smallest failing test that demonstrates the bug. This test must fail before the fix and pass after.
2. **Preparatory refactoring** (if needed) -- when the fix requires structural changes, apply the **refactoring** skill's techniques. Each refactoring commit is behaviour-preserving and independent.
3. **Fix** -- the minimal code change that makes the regression test pass.

#### Refactoring lens

When the fix involves restructuring, evaluate through the **refactoring** skill's core principles:


| Principle              | Question to ask                                                                                  |
| ---------------------- | ------------------------------------------------------------------------------------------------ |
| **Preserve behaviour** | Does every preparatory step keep the code doing exactly what it does today?                      |
| **Small steps**        | Is each transformation a single, testable change?                                                |
| **Two hats**           | Are we purely restructuring -- no new behaviour mixed in?                                        |
| **Tests first**        | Do adequate tests exist to catch regressions? If not, the regression test commit addresses this. |


For each structural change, select techniques from the **refactoring** skill catalogue. Apply the **functional-typescript** skill to ensure the fix aligns with fp-ts standards.

Design commits following the **commit-conventions** skill.

### 7. Present the fix plan

Apply the **writing-style** skill to all plan text.

Output the fix plan in this format:

```
## Fix Plan: <Title>

**Source**: <ticket link or "textual description"> | **Severity**: <severity or "n/a">

### Summary

<1--2 sentence summary of the fix approach>

### Root Cause (confirmed)

<Brief restatement of the root cause from step 4>

### Implementation Steps

| # | Type | Title | What | Key Files | Technique | Validation |
|---|------|-------|------|-----------|-----------|------------|
| 1 | commit | `test: add regression test for <bug>` | ... | `tests/...` | (prerequisite) | Test fails before fix |
| 2 | commit | `refactor: ...` | ... | `src/...` | <technique> | Tests pass |
| 3 | commit | `fix: ...` | ... | `src/...` | -- | Regression test passes |

### Notes

<Any risks, open questions, or alternative fixes considered>
```

### 8. Iterate

Wait for approval, modifications, or questions before implementing.

### 9. Implement the fix

Once the user approves, implement the fix plan **in the exact sequence presented**. Build the TODO list and execute each item following the **plan-execution** skill.

### 10. Evolve

Follow the **continuous-improvement** skill.