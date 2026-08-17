---
name: report-bug-g
description: File a bug report with reproduction steps in one pass -- creates the ADO Bug work item and investigates the codebase to write minimal repro steps. Use when the user wants to report a bug thoroughly without invoking create-bug and write-repro-steps separately.
---

# Report Bug

Create a well-documented bug report in a single invocation: file the work item AND write reproduction steps by investigating the codebase.

## Input

The user describes the bug:
- **Symptoms**: what's broken, error messages, affected area
- **Context**: how it was discovered, environment, user impact
- **Severity** (optional): if not specified, infer from symptoms

## Steps

### 1. Create the bug work item

Invoke `/create-bug-g` internally with the user's description.
- Creates an ADO Bug with proper fields (title, description, severity, area path)
- Returns the work item ID

### 2. Investigate for reproduction steps

Invoke `/write-repro-steps-g` internally with the new work item ID.
- Searches the codebase for the affected code paths
- Identifies the minimal sequence of actions to trigger the bug
- Determines preconditions (data state, config, environment)

### 3. Write repro steps onto the work item

Update the work item's Repro Steps field with:
- **Preconditions**: environment setup, data state
- **Steps**: numbered minimal reproduction sequence
- **Expected**: what should happen
- **Actual**: what happens instead
- **Evidence**: relevant code references, log patterns

### 4. Present result

Show the user:
- Work item ID and link
- Filed severity and area
- Summary of repro steps written

If the user wants to proceed to fix it immediately, suggest `/fix-bug-g <work-item-id>`.

### 5. Evolve

Follow the **capture-improvement-g** skill.
