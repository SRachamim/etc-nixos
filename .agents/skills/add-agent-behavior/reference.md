# Add Agent Behavior -- Deployment Reference

Where each customisation type lands per agent. The renderers live in `home/programs/agents/default.nix`; skills, MCP servers and `AGENTS.md` still deploy from `home/shared.nix`. Update this file whenever a renderer changes.

## Type matrix

Each cell shows **native** deployment, or *fallback* (closest supported type).

| Type | Claude Code | Cursor | Gemini CLI | Antigravity | Codex |
|------|-------------|--------|------------|-------------|-------|
| Always-on instruction | **`~/.claude/CLAUDE.md`** imports `~/.agents/AGENTS.md` | none: user rules are UI-only | **`~/.gemini/AGENTS.md`** | **`~/.gemini/AGENTS.md`** | **`~/.codex/AGENTS.md`** |
| Output style | **`~/.claude/output-styles/`** | *skill* `~/.cursor/skills/<name>-output-style/` | *skill* `~/.gemini/skills/output-styles/` | *knowledge item* `<name>-output-style` | none: warns (no Codex skills deployment) |
| Skill | **`~/.claude/skills/<name>/`** (flattened) | **reads `~/.claude/skills/`** | **`~/.gemini/skills/`** | *knowledge item* (`SKILL.md` only; siblings dropped) | none yet |
| MCP server | **`~/.claude.json`** (activation merge) | **`~/.cursor/mcp.json`** | **`~/.gemini/settings.json`** | **`~/.gemini/config/mcp_config.json`** | **`~/.codex/config.toml`** |
| Subagent | **`~/.claude/agents/<name>.md`** | **reads `~/.claude/agents/`** | **`~/.gemini/agents/<name>.md`** | **`~/.gemini/config/agents/<name>/agent.md`** | **`~/.codex/agents/<name>.toml`** |
| Hook | **`~/.claude/settings.json`** `hooks` | **`~/.cursor/hooks.json`** | **`~/.gemini/settings.json`** `hooks` | **`~/.gemini/config/hooks.json`** | **`~/.codex/hooks.json`** (approve with `/hooks`) |
| Hook fallback file | `~/.claude/rules/agent-fallbacks.md` | none: warns | `~/.gemini/GEMINI-CLI.md` (Gemini CLI only) | `~/.gemini/config/rules/agent-fallbacks.md` | appended to `~/.codex/AGENTS.md` |

Every agent also receives the portable subagent prompts at `~/.agents/subagents/`.

## Hooks

The generic events map only to exact equivalents. A missing cell means that agent gets the hook's `fallback`.

| Generic event | Claude | Cursor | Gemini CLI | Antigravity | Codex |
|---------------|--------|--------|------------|-------------|-------|
| `sessionStart` | SessionStart | sessionStart | SessionStart | -- | SessionStart |
| `promptSubmit` | UserPromptSubmit | beforeSubmitPrompt | BeforeAgent | -- (PreInvocation fires per LLM call) | UserPromptSubmit |
| `preToolUse` | PreToolUse | preToolUse | BeforeTool | PreToolUse | PreToolUse |
| `postToolUse` | PostToolUse | postToolUse | AfterTool | PostToolUse | PostToolUse |
| `stop` | Stop | stop | AfterAgent | Stop | Stop |
| `notification` | Notification | -- | Notification | -- | -- |

Tool classes (the `matcher` of the tool events):

| Class | Claude | Cursor | Gemini CLI | Antigravity | Codex |
|-------|--------|--------|------------|-------------|-------|
| `shell` | `Bash` | `Shell` | `run_shell_command` | `run_command` | `Bash` |
| `edit` | `Edit\|Write\|MultiEdit\|NotebookEdit` | `Write\|Delete` | `write_file\|replace` | `write_to_file\|replace_file_content\|multi_replace_file_content` | `apply_patch\|Edit\|Write` |
| `read` | `Read\|Grep\|Glob` | `Read\|Grep` | `read_file\|read_many_files\|glob\|grep_search\|list_directory` | `view_file\|list_dir\|grep_search\|find_by_name` | -- (reads go through the shell) |
| `mcp` | `mcp__.*` | `MCP:.*` | `mcp_.*` | `mcp_.*` | `mcp__.*` |

Shared runtime contract: stdin is the agent's own event JSON (`AGENT_HOOK_AGENT` names the agent), and exit 2 with a reason on stderr blocks the action. On exit 0 with empty stdout, the wrapper prints the agent's "allow" payload (`{"permission":"allow"}` for Cursor's `preToolUse`, `{"decision":"allow"}` for Antigravity's `PreToolUse`, `{}` otherwise).

## Code intelligence and plugins

- **Code intelligence** has no generic pipeline. Claude Code gets LSP only through a marketplace plugin, Cursor has it built into the IDE, and Gemini CLI and Codex have none (MCP bridges exist). Put the language server in `home.packages`; add a Claude plugin only when the user asks for one.
- **Plugins** package artifacts for distribution to other people. For the user's own repositories, the Nix deployment above already plays that role.

## Sources and confidence

The mappings follow the agents' docs as of 2026-09:

- Claude Code: https://code.claude.com/docs/en/hooks, `/sub-agents`, `/output-styles`
- Cursor: https://cursor.com/docs/hooks, `/subagents`
- Gemini CLI: `docs/hooks/`, `docs/core/subagents.md` in google-gemini/gemini-cli
- Codex: https://learn.chatgpt.com/docs/hooks, `/agent-configuration/subagents`

Antigravity's docs were not reachable. Its hook, agent and rules paths, and its tool names, come from third-party write-ups (atamel.dev), so check them first when an Antigravity artifact misbehaves. The same applies to Cursor honouring Claude's `model` aliases in `~/.claude/agents/`.
