# etc-nixos

Personal NixOS configuration and AI agent ecosystem. Manages system
configuration for a Dell Precision 5530 / macOS workstation and deploys
user-level agent artifacts (skills, subagent prompts, hooks, MCP config)
to Cursor, Claude Code, and Gemini CLI via home-manager.

## Repository structure

```
.
├── configuration.nix          NixOS entry point; imports all modules
├── home.nix                   home-manager: agent deployment, shell, git, editor
├── *.nix                      System modules (boot, hardware, networking, etc.)
│
├── home/
│   ├── file/
│   │   ├── agents/            Canonical source for all agent artifacts
│   │   │   ├── AGENTS.md      Global agent instructions
│   │   │   ├── CLAUDE.md      Claude Code adapter (imports AGENTS.md)
│   │   │   ├── hooks.json     Cursor pre-commit/push hook
│   │   │   ├── settings.json  Cursor IDE settings seed
│   │   │   ├── skills/        Agent skills (see below)
│   │   │   └── subagents/     Subagent prompt templates (see below)
│   │   ├── git-hooks/         Global git commit-msg hook
│   │   ├── zellij/layouts/    Terminal multiplexer layouts
│   │   ├── ghostty/           Terminal emulator config
│   │   └── aerospace/         macOS window manager config
│   └── programs/
│       ├── neovim/            Neovim plugins and agentic.nvim (Cursor ACP)
│       └── .zshrc             Shell helpers and secrets sourcing
│
├── .cursor/rules/             Repo-local Cursor rules (for editing this repo)
└── .claude/rules/             Repo-local Claude rules (for editing this repo)
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

Each skill is a directory containing a `SKILL.md` with YAML frontmatter
(name, description) and optional companion files (e.g. `reference.md`).

### Subagent prompts

Prompt templates for delegated sub-tasks that run in a separate agent
context. Each subagent is a single Markdown file in
`home/file/agents/subagents/`. See the
[subagents README](home/file/agents/subagents/README.md) for conventions.

### Hooks

- **Cursor hook** (`hooks.json`): LLM-based pre-commit/push validator
  enforcing GB English, commit conventions, and branch protection.
- **Git hook** (`git-hooks/commit-msg`): Mechanical commit message
  validation (length, banned vocabulary, AI trailer stripping).

### MCP servers

Configured in `home.nix` and deployed to `~/.cursor/mcp.json`:

| Server | Purpose |
|--------|---------|
| Azure DevOps | Work item lifecycle |
| Currents | Test analytics |
| Slack | Messaging |
| Datadog | Observability |

## Deployment

`home.nix` deploys agent artifacts via home-manager to multiple targets:

```
home/file/agents/skills/     ->  ~/.agents/skills/
                                 ~/.cursor/skills/
                                 ~/.claude/skills/
                                 ~/.gemini/skills/

home/file/agents/subagents/  ->  ~/.agents/subagents/
                                 ~/.cursor/subagents/
                                 ~/.claude/subagents/
                                 ~/.gemini/subagents/

home/file/agents/AGENTS.md   ->  ~/.agents/AGENTS.md
                                 ~/.gemini/AGENTS.md

home/file/agents/CLAUDE.md   ->  ~/.claude/CLAUDE.md
```

Apply changes with:

```sh
# NixOS (full system + home-manager)
sudo nixos-rebuild switch

# macOS (home-manager only)
home-manager switch
```

## Evolving the ecosystem

Use the `/add-agent-behavior` skill to classify and create new artifacts.
It determines whether new behaviour belongs in a workflow skill, knowledge
skill, shared skill, or subagent prompt, checks for overlap with existing
artifacts, and creates the file in the correct location.

After any artifact change, the `continuous-improvement` skill evaluates
whether the change warrants updates to related artifacts.

Repo-local rules (`.cursor/rules/evolve-new-artifacts.mdc`) enforce
that every new or modified skill includes an evolution step, a mode-gate
assessment, and a portability check.
