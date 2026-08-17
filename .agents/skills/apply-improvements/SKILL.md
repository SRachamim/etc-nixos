---
name: apply-improvements
description: Reads pending improvement observations from the shared filesystem location, skeptically evaluates each, and applies approved changes to skill source files in this repository. Repo-local skill for the dotfiles workspace only.
disable-model-invocation: true
---

# Apply Improvements

Read pending improvement observations persisted by **capture-improvement-g** (or **review-retrospective-g**) and apply them to skill source files in this repository. This skill is the "Curator" in the producer/consumer pipeline -- it does NOT blindly apply suggested diffs but independently evaluates each observation.

## Prerequisites

This skill only works in the dotfiles repository (etc-nixos) where skill source files live under `home/file/agents/skills/`.

## Steps

### 1. Read pending observations

List files in `~/.local/share/agent-improvements/pending/`. If none exist, inform the user and stop.

For each file, read the YAML frontmatter and body. Present a summary table:

```
| # | Observed | Category | Affected artifact | Confidence | During |
|---|----------|----------|-------------------|------------|--------|
```

### 2. Classify complexity

For each observation, classify its complexity to determine the evaluation approach:

| Complexity | Examples | Evaluation approach |
|---|---|---|
| **Mechanical** | Typo, missing field, better default, deprecated reference | Verify the issue is still present in the source file, apply directly |
| **Non-trivial amendment** | New step, restructuring, accuracy improvement | Apply **prior-art-research-g** to evaluate the suggested approach, survey neighboring artifacts, plan own fix |
| **New artifact / major redesign** | Observation reveals a gap needing a new skill or significant restructuring | Delegate to `/add-agent-behavior` for the full creation workflow |

### 3. Evaluate

For each observation (starting with mechanical, then non-trivial):

1. **Verify the issue is still present.** Read the affected source file under `home/file/agents/skills/`. The observation may be stale if the artifact was already updated.
2. **Assess the suggested fix.** Is it the right approach? Could a different change address the root cause better? Should the fix target a different artifact?
3. **Plan the actual change.** The suggested diff is advisory input. Plan your own edit based on the evaluation.

Present the evaluation and planned change to the user for each observation. Wait for approval before applying.

### 4. Apply approved changes

For each approved observation:

1. Apply the planned edit to the source file under `home/file/agents/skills/`.
2. If the change affects a workflow skill, verify that the `workflow-catalog-g`, `follow-up-map-g`, and `CLAUDE.md` catalog remain consistent.
3. Move the observation file from `pending/` to `applied/`.

For rejected observations, move to `rejected/`.

### 5. Commit

Commit all approved changes following the workspace's Git conventions. Group related changes (e.g., multiple observations affecting the same artifact) into a single commit where it makes sense.

### 6. Evolve

Follow the **capture-improvement-g** skill.
