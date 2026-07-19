---
name: agent-compatibility
description: Verifies that a skill or workspace rule stays portable across AI agents. Provides a portability checklist for SKILL.md files and applies the portable/generated/agent-specific trichotomy for workspace rules. Use whenever creating or modifying skills, rules, or subagent prompts.
---

# Agent Compatibility

Skills authored in this repository are deployed to multiple agents via Nix (Cursor, Claude Code, Gemini CLI, Antigravity). This skill ensures new or modified artifacts remain portable.

## Portability checklist for SKILL.md files

Apply this checklist when creating or modifying any skill:

### Frontmatter

- **Use base spec fields.** `name` and `description` are required and universal. All 32+ SKILL.md-compatible agents read them.
- **Accepted extensions.** `disable-model-invocation`, `paths`, and `metadata` are safe -- agents that don't recognise them silently ignore unknown fields.
- **Avoid agent-specific-only fields** that would break discovery in other agents. If you need an agent-specific field (e.g. Claude's `context: fork`), verify it is ignored (not errored) by other agents before adding it.

### Body content

- **No hard references to agent-specific tools.** Do not write "Call `SwitchMode`" without a graceful degradation path. Instead: "If mode switching is available, use it; otherwise, state the constraint and proceed." The **mode-gate** skill already handles this pattern.
- **Cross-references use the portable `**skill-name**` pattern.** Write "Follow the **commit-conventions** skill" rather than "Read `~/.cursor/skills/knowledge/commit-conventions/SKILL.md`". All agents resolve skill references by name.
- **No absolute paths to agent directories.** Use relative references like "the canonical source at `home/file/agents/skills/`" rather than `~/.cursor/skills/` or `~/.claude/skills/`.

### Supporting files

- **POSIX-compatible scripts.** If the skill includes `scripts/`, use `#!/usr/bin/env bash` and POSIX utilities. Avoid agent-specific script APIs.
- **Relative paths in references.** `reference.md`, `guide.md`, and other sibling files should be referenced with relative paths from the SKILL.md.

## Trichotomy for workspace rules

When a skill creates or references workspace rules, classify each asset:

| Category | What to do | Example |
|----------|-----------|---------|
| **Portable** | Content that works in plain markdown for any agent. Deploy to `AGENTS.md` at repo root. | Coding conventions, build commands, architecture notes |
| **Generated** | Same intent, different format per agent. Author once, render into each format. | `.cursor/rules/*.mdc` (with `globs:`) and `.claude/rules/*.md` (with `paths:`) |
| **Agent-specific** | Unique to one agent, no equivalent elsewhere. Keep in the agent's native directory. | Cursor `alwaysApply: true`, Claude `@import` syntax |

See the **workspace-rules** skill for the full decision process and format examples.

## Deployment verification

After creating or modifying a skill in this dotfiles repo:

- Verify the file is under `home/file/agents/skills/` (not a stale `home/file/cursor/` path).
- Nix deployment fans out skills to: `~/.claude/skills/` and `~/.gemini/skills/`. Skills are NOT deployed to `~/.agents/skills/` or `~/.cursor/skills/` because Cursor scans all these paths but fails to deduplicate between them. Cursor discovers skills from `~/.claude/skills/` as the single source.
- The `AGENTS.md` is deployed to: `~/.agents/AGENTS.md`, `~/.gemini/AGENTS.md`, `~/.codex/AGENTS.md`. Codex, Gemini CLI, and Antigravity read these at session start.
- The `CLAUDE.md` at `~/.claude/CLAUDE.md` imports `@~/.agents/AGENTS.md` for Claude Code.
- Copilot (Agent mode) reads `AGENTS.md` at repo root; no separate global deployment is needed beyond the repo-root file.
