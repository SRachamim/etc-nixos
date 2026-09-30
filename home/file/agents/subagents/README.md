# Subagent Prompts

Prompt templates for delegated sub-tasks that run in a separate agent context.
Use when work is parallelisable, needs isolation, or benefits from a dedicated
tool set.

## Naming

Each subagent is a single Markdown file: `<name>.md` (e.g. `explorer.md`,
`reviewer.md`). The filename (without extension) is the subagent identifier
used when spawning it from a skill.

## Structure

Each file starts with flat YAML frontmatter, read by the Nix renderer:

```yaml
---
name: explorer            # identifier; lowercase, hyphens
description: ...          # what it does and when to delegate to it
tier: volume              # volume | standard | frontier (AGENTS.md Model Routing)
readonly: true            # true forbids file writes
---
```

The body is the subagent's system prompt and should contain:

- **Title and one-line description** -- what the subagent does.
- **Context** -- what inputs the subagent receives from the caller.
- **Instructions** -- what the subagent must do, in order.
- **Output** -- what the subagent must return to the caller.
- **Constraints** -- permissions, model tier, isolation requirements
  (e.g. read-only, worktree-isolated).

## Deployment

`home/programs/agents/default.nix` renders each file into every agent's
native subagent format:

| Target | Agent | Tier / readonly mapping |
|--------|-------|-------------------------|
| `~/.claude/agents/<name>.md` | Claude Code, Cursor (reads this path) | `model` haiku / sonnet / opus; `disallowedTools` and Cursor's `readonly` |
| `~/.gemini/agents/<name>.md` | Gemini CLI | read-only `tools` allowlist |
| `~/.gemini/config/agents/<name>/agent.md` | Antigravity | -- |
| `~/.codex/agents/<name>.toml` | Codex | `model_reasoning_effort` low / medium / high; `sandbox_mode` |

`home/shared.nix` also copies the directory as is to `~/.agents/subagents/`
for agents or skills that pass a prompt file to a generic subagent.

## Related

- **add-agent-behavior** skill -- classifies new behaviour and creates
  subagent prompts here when appropriate.
- **skills/** -- workflow, knowledge, and shared skills that may delegate
  to subagents defined in this directory.
