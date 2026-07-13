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
# macOS (nix-darwin + home-manager) -- or just: switch
sudo darwin-rebuild switch --flake .#macbook

# NixOS (full system + home-manager)
sudo nixos-rebuild switch --flake .#SaharRachamim
```

## Common tasks

### Update all packages

```sh
nix flake update          # updates flake.lock with latest versions
switch                    # rebuild with new versions
```

To update a single input (e.g. only home-manager):

```sh
nix flake update home-manager
switch
```

### Add a package

Shared across both hosts -- append to `home.packages` in `home/shared.nix`:

```nix
home.packages = with pkgs; [
  # ... existing packages ...
  htop    # <-- add here
];
```

For NixOS system packages, edit `modules/nixos/environment.nix` instead.
For macOS GUI apps not in nixpkgs, add a Homebrew cask (see below).

### Add a shell alias

In `home/shared.nix`, append to `programs.zsh.shellAliases`:

```nix
shellAliases = {
  # ... existing aliases ...
  ll = "lsd -la";    # <-- add here
};
```

### Add a macOS system default

Edit `modules/darwin/defaults.nix`. Find the right namespace on the
[nix-darwin options search](https://searchix.alanpearce.eu/options/darwin-unstable):

```nix
system.defaults = {
  dock.tilesize = 48;              # <-- example
  NSGlobalDomain.AppleShowScrollBars = "Always";
};
```

### Add a Homebrew cask

Edit `modules/darwin/homebrew.nix`. For third-party casks, add the tap first:

```nix
homebrew = {
  taps = [
    "some-org/tap"        # <-- needed for third-party casks
  ];
  casks = [
    "some-org/tap/app"    # <-- fully qualified name
    "vanilla-cask"        # <-- official casks need no tap
  ];
};
```

### Add a dotfile

1. Place the config file in `home/file/<app>/` (e.g. `home/file/wezterm/wezterm.lua`).
2. Add a `home.file` entry in `home/shared.nix` (or `home/darwin.nix` for macOS-only):

```nix
home.file."wezterm-config" = {
  target = ".config/wezterm/wezterm.lua";
  source = ./file/wezterm/wezterm.lua;
};
```

### Add an MCP server

In `home/shared.nix`, add an entry to `mcpServers` using the `mkMcpServer` helper:

```nix
mcpServers = {
  # ... existing servers ...
  "New Server" = {
    command = mkMcpServer "mcp-new-server" "@org/mcp-server@latest";
  };
};
```

The server is automatically deployed to Cursor, Claude Code, Gemini CLI,
and Codex configs.

### Roll back

```sh
# macOS -- switch to the previous nix-darwin generation
sudo darwin-rebuild switch --rollback

# List home-manager generations
home-manager generations
```

### Add a new host

1. Create `hosts/<name>/configuration.nix` (and `hardware-configuration.nix`
   for NixOS).
2. Add a new entry in `flake.nix` under `nixosConfigurations` or
   `darwinConfigurations`.
3. Import the appropriate modules and home-manager config.

## Secrets

API keys and tokens are kept in `~/.secrets` (not tracked in this repo).
The file is sourced by zsh on shell startup. A template is created
automatically by home-manager if the file doesn't exist.

## Evolving the ecosystem

Use the `/add-agent-behavior` skill to classify and create new artifacts.
After any artifact change, the `continuous-improvement` skill evaluates
whether the change warrants updates to related artifacts.
