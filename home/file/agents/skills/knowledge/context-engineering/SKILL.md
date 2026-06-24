---
name: context-engineering
description: Strategies for managing the agent context window as a scarce resource -- isolate, select, compress, budget. Use whenever the agent runs a multi-step workflow, spawns subagents, or notices context accumulating beyond what the current step needs.
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

- **During `/plan`:** partition exploration across focused subagents; summarise findings before drafting the plan.
- **During `/debug`:** isolate investigation steps; compress evidence into a root-cause summary before proposing a fix.
- **During `/review-pr`:** load only the diff and directly relevant source files, not the entire repository.
- **When spawning subagents:** give each subagent the narrowest context that lets it complete its task.
- **When a session runs long:** write a scratchpad summary and reference it rather than relying on accumulated history.

## Related skills

- **architect-thinking** -- Options Thinking informs when to defer context loading; Systems Thinking informs how subagent results compose.
- **decision-priorities** -- the priority ladder (correctness > changeability > DX) applies to context trade-offs: never drop context that affects correctness to save tokens.
