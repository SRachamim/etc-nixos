# Subagent Prompts

Prompt templates for delegated sub-tasks that run in a separate agent context.
Use when work is parallelisable, needs isolation, or benefits from a dedicated
tool set.

## Naming

Each subagent is a single Markdown file: `<name>.md` (e.g. `explorer.md`,
`reviewer.md`). The filename (without extension) is the subagent identifier
used when spawning it from a skill.

## Structure

Each file should contain:

- **Title and one-line description** -- what the subagent does.
- **Context** -- what inputs the subagent receives from the caller.
- **Instructions** -- what the subagent must do, in order.
- **Output** -- what the subagent must return to the caller.
- **Constraints** -- permissions, model tier, isolation requirements
  (e.g. read-only, worktree-isolated).

## Deployment

`home.nix` deploys this directory recursively to:

| Target                   | Agent    |
|--------------------------|----------|
| `~/.agents/subagents/`   | Portable |
| `~/.cursor/subagents/`   | Cursor   |
| `~/.claude/subagents/`   | Claude   |
| `~/.gemini/subagents/`   | Gemini   |

## Related

- **add-agent-behavior** skill -- classifies new behaviour and creates
  subagent prompts here when appropriate.
- **skills/** -- workflow, knowledge, and shared skills that may delegate
  to subagents defined in this directory.
