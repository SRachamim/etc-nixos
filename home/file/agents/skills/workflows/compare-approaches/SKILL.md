---
name: compare-approaches
description: Spawns parallel agents to explore N candidate solutions to a design decision, evaluates them against decision-priorities and design-lenses, and presents a structured comparison for the user to choose from. Use when a planning or design step reveals multiple viable paths with no clear winner.
disable-model-invocation: true
---

# Compare Approaches

Given a design question with multiple viable paths, explore each candidate in parallel and present a structured comparison so the user can make an informed decision quickly.

This skill provides the **methodology** for best-of-N evaluation -- when to use it, what to explore, how to evaluate, and how to present the results. The platform provides the mechanism (parallel subagents, worktrees).

## Input

Accept **any** of the following:

1. **Design question** -- a question with multiple viable answers (e.g., "Should we use a saga or an event-sourced aggregate for cross-service order processing?").
2. **Decision point from `/plan` or `/prd-intake`** -- when step 4 (design lenses) or step 6 (tech design) reveals multiple viable paths. The calling skill passes the decision context.
3. **Explicit candidates** -- the user provides a list of approaches to compare.

## Steps

### 0. Enter Plan mode

Require **Plan** mode following the **mode-gate** skill. The entire comparison (steps 1--6) is read-only analysis.

### 1. Frame the decision

- Restate the design question in one sentence.
- Identify the **constraints** (what must be true regardless of approach).
- Identify the **degrees of freedom** (what can vary between approaches).
- Confirm the framing with the user before proceeding.

### 2. Generate candidates

If the user did not provide explicit approaches, generate 2-4 candidates. For each:

- **Label** -- a short name (e.g., "Saga with compensations", "Event-sourced aggregate").
- **Thesis** -- 1-2 sentences explaining the core idea and why it might be the right fit.

Present the candidates and confirm before exploring. The user may add, remove, or modify candidates.

### 3. Parallel exploration

Spawn one read-only **explorer** subagent per candidate. Each subagent receives:

- The design question and constraints (from step 1).
- Its specific candidate's label and thesis (from step 2).
- A directory scope hint (narrowest scope that plausibly contains the relevant code).

Each subagent explores:

- How this approach would work in the current codebase.
- Which files, modules, and interfaces it would affect.
- What extension points it leverages or new ones it requires.
- Risks, trade-offs, and open questions specific to this approach.
- Relative complexity estimate (S / M / L).

If the user requests deeper exploration (e.g., "prototype each approach"), spawn **implementer** subagents in worktree-isolated environments instead.

Collect all subagent results before proceeding.

### 4. Evaluate

Apply the **decision-priorities** skill and the **design-lenses** skill (planning framing) across all candidates:

- Score each candidate against the priority ladder: correctness, changeability, DX.
- Identify the 2-3 most relevant design-lens principles for this decision and assess each candidate against them.
- Note where candidates are equivalent (don't manufacture differences).

### 5. Present comparison

Output a structured comparison:

```
## Comparison: <Design Question>

### Candidates

| # | Approach | Thesis |
|---|----------|--------|
| A | ... | ... |
| B | ... | ... |

### Evaluation

| Criterion | Approach A | Approach B |
|---|---|---|
| Correctness | ... | ... |
| Changeability | ... | ... |
| DX | ... | ... |
| Complexity | S/M/L | S/M/L |
| Key risk | ... | ... |

### Recommendation

**Strongest candidate**: <label> -- <rationale in 1-2 sentences>.

### What we'd lose

- **If not A**: <what this approach uniquely offers that we forgo>
- **If not B**: <what this approach uniquely offers that we forgo>
```

### 6. Iterate

Wait for the user to choose. Once they decide:

- If invoked from `/plan`: return the chosen approach as the design input for step 5 (draft the plan).
- If invoked from `/prd-intake`: return the chosen approach for the tech design section.
- If invoked standalone: suggest invoking `/plan` with the chosen approach.

### 7. Evolve

Follow the **continuous-improvement** skill.

## When NOT to use this skill

- When there is only one obvious approach -- just proceed with `/plan`.
- When the decision is trivial -- apply **decision-priorities** inline without spawning subagents.
- When the decision is purely about naming, style, or cosmetics -- not architectural.
- When the candidates differ only in effort, not in design shape -- just note the trade-off and pick.
