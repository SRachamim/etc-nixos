# Agent Hooks

Lifecycle hooks written once and deployed to every supported agent. Use a
hook when something must happen every time, with no reasoning needed:
formatting after edits, blocking unsafe commands, logging, notifications.
An instruction in `AGENTS.md` or a skill is a request. A hook is
enforcement.

## Structure

Each hook is a directory `<name>/` containing:

- `hook.json` -- the generic definition:

  ```json
  {
    "description": "Block edits to .env files",
    "event": "preToolUse",
    "matcher": "edit",
    "packages": ["jq"],
    "fallback": "Never edit .env files; ask the user to change them."
  }
  ```

  | Field | Values |
  |-------|--------|
  | `event` | `sessionStart`, `promptSubmit`, `preToolUse`, `postToolUse`, `stop`, `notification` |
  | `matcher` | `any` (default), `shell`, `edit`, `read`, `mcp`. Used only by the tool events |
  | `packages` | nixpkgs attribute names put on the script's `PATH` |
  | `fallback` | Standing instruction for agents that have no equivalent event or tool class |

- `run.sh` -- a bash script, checked by shellcheck at build time.
  - It receives the agent's event JSON on stdin. Field names differ per
    agent, and `AGENT_HOOK_AGENT` (`claude`, `cursor`, `gemini`,
    `antigravity`, `codex`) says which one is calling.
  - Exit 0 with no output to allow the action. The wrapper prints the
    agent's own "allow" payload.
  - Exit 2 with a reason on stderr to block the action. All five agents
    share this contract.

## Deployment

`home/programs/agents/default.nix` maps the event and tool class onto each
agent's native names and writes:

| Agent | Target |
|-------|--------|
| Claude Code | `~/.claude/settings.json` `hooks`, merged with the workmux hooks |
| Cursor | `~/.cursor/hooks.json` |
| Gemini CLI | `~/.gemini/settings.json` `hooks` |
| Antigravity | `~/.gemini/config/hooks.json` |
| Codex | `~/.codex/hooks.json`. Approve new or changed hooks once with `/hooks` |

When an agent has no equivalent, the hook's `fallback` goes into an
instructions file that only that agent reads:

| Agent | Instructions file |
|-------|-------------------|
| Claude | `~/.claude/rules/agent-fallbacks.md` |
| Gemini CLI | `~/.gemini/GEMINI-CLI.md` |
| Antigravity | `~/.gemini/config/rules/agent-fallbacks.md` |
| Codex | appended to `~/.codex/AGENTS.md` |
| Cursor | none; the build prints a warning |

The full per-agent event and matcher tables live in the
**add-agent-behavior** skill's `reference.md`.
