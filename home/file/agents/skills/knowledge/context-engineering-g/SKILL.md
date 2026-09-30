---
name: context-engineering-g
description: Strategies for managing the agent context window as a scarce resource -- isolate, select, compress, budget -- and the model tier for each task. Use whenever the agent runs a multi-step workflow, spawns subagents, or notices context accumulating beyond what the current step needs.
---

# Context Engineering

The context window is a constrained budget, not an infinite resource. Every token competes for the model's attention; as context grows, precision drops, reasoning weakens, and cost rises. Smaller, well-curated context is faster, cheaper, and more accurate simultaneously.

## Core strategies

### Isolate

Distribute work across subagents with narrow, focused contexts. A subagent that only sees the files it needs outperforms one that sees everything.

- **Read-only subagents** (explorers, reviewers) need no filesystem isolation -- give them a focused prompt and a scoped file list.
- **Writing subagents** (implementers, test writers) need worktree isolation to prevent filesystem collisions when running in parallel.
- **High-conflict files** (shared config, schema definitions, index files) should be written only by the parent agent or a designated merge step, never by parallel workers.

Before spawning subagents, partition the work so each agent owns a disjoint set of concerns. The parent collects results and synthesises.

#### Parallel exploration

When a workflow needs to understand an area of the codebase and the agent can run subagents in parallel, prefer this over sequential search:

1. Decompose the goal into 2--5 focused questions. The calling workflow supplies its typical questions.
2. Spawn one read-only **explorer** subagent per question, giving it the question and the narrowest directory or file scope that plausibly contains the answer.
3. Collect every result before proceeding.
4. Synthesise the results into the output the calling workflow names.

When parallel execution is unavailable, the calling workflow's sequential steps apply.

### Select

Load only what the current step needs. Prefer precision over recall.

- **Skills:** prefer description-based activation over `alwaysApply`. A skill that is always loaded but rarely relevant wastes budget on every call.
- **Files:** read targeted sections (line ranges, grep results) rather than entire files when the relevant code is localised.
- **Tool output:** filter and trim tool responses at ingestion. API results, search results, and command output are often the largest context consumers -- extract only what the next step needs.
- **Rules:** scope rules with glob patterns where possible. A rule that fires only for `**/*.test.ts` consumes zero tokens when editing production code.

### Compress

Replace accumulated history with structured summaries when context grows.

- **Scratchpad pattern:** for long sessions, write a scratchpad file (e.g. `.cursor/scratchpad.md`) that captures key findings, decisions, and remaining work. Reference the file instead of relying on chat history to carry forward state.
- **Summarise, don't accumulate:** after an exploration or analysis phase, distil findings into a concise summary before starting the next phase. Drop the raw evidence from context.
- **Reference files over inline content:** for large reference material (API schemas, architecture docs), point to the file path rather than pasting contents into the prompt. Read targeted sections on demand.

### Budget

Target 60--80% context utilisation. Leaving headroom preserves reasoning quality.

- **Simple tasks get minimal context.** A rename or typo fix does not need architecture documentation.
- **Complex tasks get structured context.** A cross-repo refactor needs the relevant interfaces, tests, and dependency graph -- but not the entire codebase.
- **Measure tokens per finished task**, not tokens per call. A 12-turn agent that finishes the task with 30K total tokens is better than one that uses 200K.

## Model routing

Classify tasks by cognitive demand and select the matching model tier. Subagents declare their tier in frontmatter, and `home/programs/agents/default.nix` maps tiers to each agent's models.

| Tier | Cognitive demand | Task examples | Model guidance |
|------|-----------------|---------------|----------------|
| **Frontier** | Complex reasoning, long-chain planning, cross-cutting architectural judgement | Architecture decisions, security audits, complex cross-repo debugging, multi-file refactors with subtle dependency chains | Use the most capable model available. ~5-15% of tasks. |
| **Standard** | Multi-step reasoning, moderate context | Standard implementation, code review, test generation, single-file refactoring, PR descriptions | Use the platform's default/recommended model. ~25-35% of tasks. |
| **Volume** | Mechanical, well-scoped, low ambiguity | Boilerplate, documentation, classification, bulk file edits, read-only exploration subagents, commit message drafting | Use the fastest/cheapest model available. ~50-60% of tasks. |

### Routing rules

- When spawning subagents, default to **Volume** tier unless the task requires reasoning across multiple files or domains.
- When the agent can choose its own model, select based on tier.
- When the platform doesn't support model selection, ignore this section -- the guidance is advisory, not blocking.

### Escalation heuristic

If a Volume-tier task fails or produces low-quality output on the first attempt, retry at Standard tier before involving the user. If a Standard-tier task fails, escalate to Frontier. Don't retry at the same tier more than once.

## Prompt caching

Keep the stable prefix of context (system prompt, tool definitions, always-applied rules) identical across calls. Provider APIs offer steep discounts on cached prefix tokens.

- Do not reorder context between calls -- this invalidates the cache.
- Keep `AGENTS.md` and always-applied rules structurally stable.
- Place volatile content (conversation history, tool results) after the stable prefix.

## Anti-patterns

| Mistake | Consequence |
|---------|-------------|
| Stuffing the full codebase into context | Reasoning degrades; cost scales linearly with irrelevant tokens |
| Using `alwaysApply` for niche rules | Every conversation pays the token tax, even when the rule is irrelevant |
| Spawning subagents that each see everything | Multiplies context cost N-fold with no quality gain |
| Relying on chat history for long-running sessions | Context rots as old turns push relevant information out of the attention window |
| Reordering system prompt or tool definitions between calls | Invalidates prompt cache; silently increases cost |
| Optimising tokens per request instead of tokens per task | Aggressive compression forces re-fetching, increasing total cost |

## Applying this skill

This skill is passive guidance, not a workflow. The agent applies it whenever making context-related decisions during other workflows:

- **During `/plan-g`:** partition exploration across focused subagents; summarise findings before drafting the plan.
- **During `/debug-g`:** isolate investigation steps; compress evidence into a root-cause summary before proposing a fix.
- **During `/review-pr-g`:** load only the diff and directly relevant source files, not the entire repository.
- **When spawning subagents:** give each subagent the narrowest context that lets it complete its task.
- **When a session runs long:** write a scratchpad summary and reference it rather than relying on accumulated history.

## Related skills

- **architect-thinking-g** -- Options Thinking informs when to defer context loading; Systems Thinking informs how subagent results compose.
- **decision-priorities-g** -- the priority ladder (correctness > changeability > DX) applies to context trade-offs: never drop context that affects correctness to save tokens.
