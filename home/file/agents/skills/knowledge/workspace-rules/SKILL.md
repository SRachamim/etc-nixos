---
name: workspace-rules
description: Guides creation of workspace-level rules that work across multiple agents. Applies the portable/generated/agent-specific trichotomy to decide where rule content lives and how it reaches each agent. Use whenever the agent creates or modifies workspace rules in any repository.
---

# Workspace Rules

Workspace rules are instructions scoped to a specific repository. Different agents use different formats and paths for these rules. This skill applies the **portable / generated / agent-specific** trichotomy to ensure rule content reaches every agent without forcing one agent's format onto another.

## The trichotomy for workspace rules

| Category | Description | Examples |
|----------|-------------|----------|
| **Portable** | Same markdown content, every agent reads it from a standard path. | `AGENTS.md` at repo root |
| **Generated** | Same intent, different format per agent. Author the rule once, render into each agent's native format. | Cursor `.mdc` -> Claude `.md` rule with equivalent content |
| **Agent-specific** | Format or feature unique to one agent with no cross-agent equivalent. | Cursor's `globs` + `alwaysApply` frontmatter, Claude's `@import` syntax |

## Decision process

When creating or modifying a workspace rule:

1. **Write the rule content in plain markdown first.** Focus on the intent: what should the agent do, when, and why.

2. **Classify each part of the rule:**
   - The *content* (the instructions) is portable. It can go in `AGENTS.md`.
   - The *targeting mechanism* (glob patterns, path scoping) is agent-specific. Each agent has its own syntax.
   - The *metadata* (frontmatter fields like `alwaysApply`, `description`) is agent-specific.

3. **Deploy to agents:**

   | Agent | Rule format | Path | Targeting |
   |-------|-------------|------|-----------|
   | **Cursor** | MDC with YAML frontmatter | `.cursor/rules/<name>.mdc` | `globs:` field, `alwaysApply:` field |
   | **Claude Code** | Markdown, optional frontmatter | `.claude/rules/<name>.md` | `paths:` field in frontmatter |
   | **Codex** | Plain markdown | `AGENTS.md` at repo root (walks dir tree); `~/.codex/AGENTS.md` globally | Entire file loaded as context; nearest file wins |
   | **Copilot** | Plain markdown or frontmatter | `AGENTS.md` at repo root (Agent mode); `.github/copilot-instructions.md` (always-on); `.github/instructions/*.instructions.md` (file-scoped) | `applyTo:` glob in frontmatter for `.instructions.md` files |
   | **Antigravity** | Plain markdown | `AGENTS.md` or `GEMINI.md` at repo root; `.agent/rules/*.md` for scoped rules | `GEMINI.md` overrides `AGENTS.md`; `.agent/rules/` supports `globs:` frontmatter |
   | **Gemini CLI** | Loaded from context file | `AGENTS.md` or `GEMINI.md` at repo root | Entire file loaded as context |
   | **Others** (Amp, Windsurf, Aider, Zed, etc.) | Plain markdown | `AGENTS.md` at repo root | Entire file loaded as context |

4. **Ask whether the rule intent needs a portable equivalent.** If the rule applies broadly (not just to one agent's features), add the content to the repo-root `AGENTS.md` so every agent benefits.

## When NOT to create multiple formats

- If the rule relies on an agent-specific feature (e.g. Cursor's glob-scoped auto-triggering), keep it agent-specific. Don't create a broken portable version.
- If only one agent is used in the repo, use that agent's native format. Add `AGENTS.md` only when multi-agent support is needed.

## Example: same rule, three formats

**Portable content** (the intent):

> When creating or modifying skills in this repository, include a final Evolve step and verify agent compatibility.

**Cursor format** (`.cursor/rules/evolve-new-artifacts.mdc`):

```markdown
---
description: Ensure new skills include continuous-improvement and agent-compatibility steps
globs: home/file/agents/skills/**/SKILL.md
alwaysApply: false
---

# Evolve new artifacts

When creating or modifying a skill in this repository:

- Add a final step that references the **continuous-improvement** skill.
- Apply the **agent-compatibility** skill to verify portability.
```

**Claude Code format** (`.claude/rules/evolve-new-artifacts.md`):

```markdown
---
paths: home/file/agents/skills/**/SKILL.md
---

# Evolve new artifacts

When creating or modifying a skill in this repository:

- Add a final step that references the **continuous-improvement** skill.
- Apply the **agent-compatibility** skill to verify portability.
```

**AGENTS.md** (repo root, if needed): append the intent as a section.
