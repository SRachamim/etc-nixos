# etc-nixos

Personal NixOS + nix-darwin configuration with home-manager. Manages system
configuration for a Dell Precision 5530 (NixOS) and macOS workstation
(nix-darwin), and deploys user-level agent artifacts (skills, subagent
prompts, hooks, MCP config) to Cursor, Claude Code, and Gemini CLI.

## Repository structure

```
.
├── flake.nix                    Entry point; pins all inputs, defines hosts
├── flake.lock                   Locked dependency versions
│
├── hosts/
│   ├── nixos/
│   │   ├── configuration.nix    NixOS entry point
│   │   └── hardware-configuration.nix
│   └── darwin/
│       └── configuration.nix    nix-darwin entry point
│
├── modules/
│   ├── shared/
│   │   └── nix.nix              Shared Nix daemon settings
│   ├── nixos/                   NixOS-only modules (boot, services, etc.)
│   └── darwin/                  macOS-only modules (defaults, homebrew)
│
├── home/
│   ├── shared.nix               Shared home-manager config
│   ├── darwin.nix               macOS-specific home additions
│   ├── nixos.nix                NixOS-specific home additions
│   ├── file/
│   │   ├── agents/              Canonical source for all agent artifacts
│   │   │   ├── AGENTS.md        Global agent instructions
│   │   │   ├── CLAUDE.md        Claude Code adapter (imports AGENTS.md)
│   │   │   ├── hooks.json       Cursor pre-commit/push hook
│   │   │   ├── settings.json    Cursor IDE settings seed
│   │   │   ├── skills/          Agent skills (see below)
│   │   │   └── subagents/       Subagent prompt templates
│   │   ├── git-hooks/           Global git commit-msg hook
│   │   ├── zellij/layouts/      Terminal multiplexer layouts
│   │   ├── ghostty/             Terminal emulator config
│   │   └── aerospace/           macOS window manager config
│   └── programs/
│       └── neovim/              Neovim plugins and agentic.nvim
│
├── overlays/
│   └── default.nix              Custom packages (agentic-nvim)
│
├── .cursor/rules/               Repo-local Cursor rules
└── .claude/rules/               Repo-local Claude rules
```

## Agent artifacts

### Skills (63 total)

Skills are reusable instruction sets that teach agents how to handle
specific tasks. They live in `home/file/agents/skills/` and are organised
into three categories:

| Category | Count | Purpose |
|----------|-------|---------|
| **workflows/** | 33 | User-invoked procedures (`/plan`, `/review-pr`, `/triage`, etc.) |
| **knowledge/** | 26 | Standards and reference material loaded by context |
| **shared/** | 4 | Helper sub-workflows called by other skills |

### Subagent prompts

Prompt templates for delegated sub-tasks. Each subagent is a single
Markdown file in `home/file/agents/subagents/`.

### Hooks

- **Cursor hook** (`hooks.json`): LLM-based pre-commit/push validator.
- **Git hook** (`git-hooks/commit-msg`): Mechanical commit message validation.

### MCP servers

Configured in `home/shared.nix` and deployed to `~/.cursor/mcp.json`,
`~/.claude.json`, `~/.gemini/settings.json`, and `~/.codex/config.toml`:

| Server | Purpose |
|--------|---------|
| Azure DevOps | Work item lifecycle |
| Currents | Test analytics |
| Slack | Messaging |
| Datadog | Observability |

## Deployment

### Agent artifact deployment

```
home/file/agents/skills/     ->  ~/.agents/skills/
                                 ~/.cursor/skills/
                                 ~/.claude/skills/
                                 ~/.gemini/skills/

home/file/agents/subagents/  ->  ~/.agents/subagents/
                                 ~/.cursor/subagents/
                                 ~/.claude/subagents/
                                 ~/.gemini/subagents/
```

### Apply changes

```sh
# NixOS (full system + home-manager)
sudo nixos-rebuild switch --flake .#SaharRachamim

# macOS (nix-darwin + home-manager)
darwin-rebuild switch --flake .#macbook
```

## Secrets

API keys and tokens are kept in `~/.secrets` (not tracked in this repo).
The file is sourced by zsh on shell startup. A template is created
automatically by home-manager if the file doesn't exist.

## Evolving the ecosystem

Use the `/add-agent-behavior` skill to classify and create new artifacts.
After any artifact change, the `continuous-improvement` skill evaluates
whether the change warrants updates to related artifacts.
