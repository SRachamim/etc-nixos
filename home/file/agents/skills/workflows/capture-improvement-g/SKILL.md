---
name: capture-improvement-g
description: Reflects on skill execution to identify improvements, then persists observations to a shared location for later curation or applies them directly. Use after any workflow execution (Evolve step) or invoke manually to capture observations from the current session.
disable-model-invocation: true
---

# Capture Improvement

After executing a skill, reflect on the execution using the **continuous-improvement-g** methodology and act on the findings. For user-level skills whose source lives outside the current workspace, persist structured observations to a shared filesystem location for later curation by a consuming skill.

## Input

- **No arguments**: scan the full thread for improvement signals across all skill and tool usage in the session.
- **Explicit focus instruction**: constrain the reflection to a specific area (e.g., "look at the MCP calls", "the plan-g execution had issues").

Resolution priority: explicit focus > full thread scan.

## Steps

### 1. Reflect

Apply the **continuous-improvement-g** methodology. Scan the thread (or focused area) for signals:

- Discovery, workaround, deprecation, redundancy, missing error handling, performance, accuracy, recurring friction, cost of inaction.

If no signals are found, stop. Do not propose improvements for their own sake.

### 2. Propose

For each signal found, follow the **continuous-improvement-g** proposal format:

1. **State what happened** -- one sentence describing the discrepancy.
2. **Categorize** -- label as: new-field, deprecated, better-default, missing-step, dead-step, error-handling, accuracy, or performance.
3. **Show the proposed change** -- before/after diff against the source file.

Present all proposals to the user for approval. Only approved observations proceed to the next step.

### 3. Act

For each approved observation, classify the artifact scope and route accordingly:

**Path 1 -- workspace-level artifact** (source is in the current workspace):

Apply the edit directly as a preceding commit, following the workspace's Git conventions. This covers repo-local rules (`.cursor/rules/`, `.claude/rules/`), workspace `AGENTS.md`, and any repo-level skills.

**Path 2 -- user-level (`-g`) skill** (source lives in the dotfiles repo, not the current workspace):

Write a structured observation file to `~/.local/share/agent-improvements/pending/`. The file captures evidence and a suggested fix -- the consuming skill will independently evaluate whether and how to address the issue.

Observation file format:

```yaml
---
source-skill: <this-skill-or-review-retrospective-g>
observed-during: <workflow-that-triggered-reflection>
affected-artifact: <path-relative-to-dotfiles-repo>
category: <category-from-step-2>
confidence: <high|medium|low>
observed-at: <ISO-8601-timestamp>
workspace: <absolute-path-to-current-workspace>
---
```

Followed by:

```markdown
## What happened

<one sentence from step 2>

## Suggested change

<before/after diff from step 2 -- advisory, not prescriptive>
```

Filename: `{ISO-timestamp}_{category}_{affected-skill-name}.md` (e.g., `2026-08-17T10-30-00Z_missing-step_fix-build-g.md`).

Also present the observation in the conversation so the user sees what was persisted.

**Path 3 -- truly external** (neither workspace-local nor dotfiles-managed):

Format the proposal as a self-contained, ready-to-paste agent instruction inside a fenced code block:

~~~text
The <command/skill/rule> at <runtime-path> needs an update.

What happened: <one sentence>
Category: <category>

Proposed change to <filename> -- <brief scope>:

<unified diff or before/after snippet>

This file lives at <path-hint> -- apply the diff there.
~~~

### 4. Follow up

Apply the **follow-up-map-g** skill to present relevant follow-up workflow skills to the user.

## Constraints

- **Evidence-based only** -- every suggestion must trace back to something that actually happened during execution. Never speculate.
- **Don't break existing behavior** -- improvements must be backward-compatible. If unsure, present the change and ask.
- **Minimal diff** -- change only what is needed. Don't reformat or restructure surrounding content.
- **User approval required** -- never persist an observation or apply an edit without user approval.

## How to determine artifact scope

To classify which path applies:

1. Check if the affected file exists in the current workspace. If yes → **Path 1** (workspace-level).
2. Check if the artifact name ends with `-g` (user-level skill suffix). If yes → **Path 2** (user-level, persist to shared location).
3. Otherwise → **Path 3** (truly external).

When in doubt, present the classification to the user and ask.
