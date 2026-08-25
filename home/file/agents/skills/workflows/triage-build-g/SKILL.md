---
name: triage-build-g
description: Diagnoses a failed Azure DevOps pipeline build and presents a structured summary of errors, failed tests, and changes. Use when given a build ID or when investigating the latest build failure on the current branch.
disable-model-invocation: true
---

# Triage Build

Given a build ID (or inferred from the current branch), diagnose a failed pipeline and summarize the failure.

## Steps

### 0. Recommended mode: Debug

Require **Debug** mode following the **mode-gate-g** skill. This command investigates a build failure -- Debug mode is the best fit.

### 1. Resolve the build

Determine the build using one of the following, in priority order:

1. **Explicit argument** -- the user provided a build ID directly.
2. **Current branch** -- find the latest build for the current branch (`git branch --show-current`).

If neither yields a build, ask the user and stop.

### 2. Fetch build details

- Fetch the build status and result.
- If the build succeeded, inform the user and stop -- nothing to triage.
- Fetch the build timeline to identify which stage and job failed.

### 3. Fetch build logs

- Get the log index for the build.
- Read the logs for the failed job(s). Focus on the last ~200 lines of each failed log to find the error.

### 4. Fetch test results

- Fetch test results from the build (Azure DevOps test results API).
- If the project uses Currents, also search for the corresponding Currents run:
  - Match by branch name and approximate time window.
  - Fetch run details for additional context (flaky tests, spec-level timing, error messages).

### 5. Fetch build changes

- Get the commits associated with this build to understand what changed.
- Cross-reference failed tests or errors with the changed files.

### 6. Summarize

Apply the **objective-communication-g** skill to all composed text.

#### Classification verification

Before classifying a failure as external/infrastructure or flaky:

1. **External/infrastructure**: Identify 2-3 recent builds from other
   authors on the same pipeline. For each, check whether it failed with
   the **same error signature** (same error messages, same Datadog error
   patterns, same failing test proportion). "Also failing" is not
   evidence -- "failing identically" is. Only classify as external if at
   least one other build reproduces the same error.

2. **Flaky/intermittent**: A test's historical flakiness rate alone is
   not sufficient. Verify that the failure is isolated:
   - If the failing test count is disproportionate (e.g., >10% of specs
     fail), suspect a systemic cause -- not flakiness.
   - If the error message differs from the test's known flaky pattern,
     treat it as a new failure.
   - Cross-check: did the same test pass in other builds running
     concurrently? If it failed everywhere, it's not flaky.

3. If verification fails for either classification, default to
   **own-code** and investigate further.

Present a structured summary:

```
## Build: <build number> -- <result>

**Pipeline**: <name> | **Branch**: <branch> | **Duration**: <time>

### Failed Stage / Job

<stage> → <job> -- <failure reason>

### Error Summary

<concise description of what went wrong, with relevant log excerpts>

### Failed Tests

| Test | Status | Details |
|------|--------|---------|
| ... | Failed | ... |
| ... | Flaky | ... (from Currents) |

### Changes in This Build

<list of commits with short messages>

### Suggested Next Steps

- <action 1>
- <action 2>
```

### 7. Offer actions

If appropriate, offer to:

- Retry the failed stage.
- Quarantine a flaky test (via Currents action).
- Open a bug work item for a genuine failure.
- Submit a bypass request (follow the **submit-bypass-request-g** skill).

Wait for user confirmation before taking any action.

### 8. Evolve

Follow the **capture-improvement-g** skill.
