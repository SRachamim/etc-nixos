# Output Styles

A role, tone, length or response format you want for a whole session and
may want to switch off again. Facts and rules about the work belong in
`AGENTS.md` instead: it stays loaded whichever style is active.

## Structure

Each style is a single Markdown file `<name>.md`:

```markdown
---
name: Diagram First
description: Answers every question with a diagram before prose.
keep-coding-instructions: true
---

<instructions that define the style>
```

- `name` is the display name.
- `description` says what the style changes.
- `keep-coding-instructions` (optional, Claude only) keeps Claude Code's
  software-engineering system prompt alongside the style.

## Deployment

`home/programs/agents/default.nix` deploys each file:

| Agent | Deployed as |
|-------|-------------|
| Claude Code | `~/.claude/output-styles/<name>.md`, the file as is. Pick it with `/output-style` |
| Gemini CLI | skill `~/.gemini/skills/output-styles/<name>-output-style/` |
| Antigravity | knowledge item `<name>-output-style` |
| Cursor | skill `~/.cursor/skills/<name>-output-style/` |
| Codex | none. The build prints a warning: there is no skills deployment for Codex yet |

The agents without output styles get the closest type, a user-invoked
skill. Invoking it switches the style on for the rest of the session.
