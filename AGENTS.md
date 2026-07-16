# Declarative Nix only

Every change to packages, services, programs, dotfiles, environment variables, shell aliases, fonts, or system settings **must** be made declaratively in this repository. Never perform or suggest imperative mutations that won't survive `nixos-rebuild switch`, `darwin-rebuild switch`, or porting to a new machine.

## Banned imperative patterns

- `brew install` / `brew cask install` (use `modules/darwin/homebrew.nix` instead)
- `apt install` / `dnf install` / `pacman -S`
- `npm install -g` / `pip install --user`
- `defaults write` / `gsettings set` (use `modules/darwin/defaults.nix` instead)
- `systemctl enable` / `launchctl load`
- Manually editing config files outside this repo (e.g. `~/.zshrc`, `~/.gitconfig`)

## Where to make changes

| Change type | File(s) |
|-------------|---------|
| Flake inputs / host definitions | `flake.nix` |
| NixOS system packages | `modules/nixos/environment.nix` |
| macOS system defaults | `modules/darwin/defaults.nix` |
| macOS Homebrew casks | `modules/darwin/homebrew.nix` |
| Shared home-manager packages / programs | `home/shared.nix` |
| macOS-specific home config | `home/darwin.nix` |
| NixOS-specific home config | `home/nixos.nix` |
| Shell config (zsh) | `home/shared.nix` (programs.zsh.initContent) |
| Dotfiles (ghostty, aerospace, zellij, etc.) | `home/file/<app>/` |
| Agent artifacts (skills, subagents, rules) | `home/file/agents/` |
| Neovim config | `home/programs/neovim/` |
| Fonts (NixOS) | `modules/nixos/fonts.nix` |
| Services (NixOS) | `modules/nixos/services.nix` |
| Networking (NixOS) | `modules/nixos/networking.nix` |
| Custom packages / overlays | `overlays/default.nix` |
| Workspace rules (Cursor) | `.cursor/rules/*.mdc` |
| Workspace rules (Claude Code) | `.claude/rules/*.md` |
| Workspace rules (all agents) | `AGENTS.md` |

Do **not** edit `hosts/nixos/hardware-configuration.nix` -- it is auto-generated.

## Workspace rules

Project context (this file) lives in `AGENTS.md` and is read by all agents. Workflow triggers -- rules that fire when specific files are modified -- live in each agent's native rule system:

| Agent | Rule location | Format |
|-------|--------------|--------|
| Cursor | `.cursor/rules/*.mdc` | YAML frontmatter with `globs:` |
| Claude Code | `.claude/rules/*.md` | YAML frontmatter with `globs:` |

When adding a new workflow trigger, create it in **every** rule directory above so all agents enforce it. When onboarding a new agent tool, replicate all existing triggers from `.cursor/rules/` and `.claude/rules/` into the new tool's native format.

## Common patterns

### Add a home-manager package

In `home/shared.nix`, append to the `home.packages` list:

```nix
home.packages = with pkgs; [
  # ... existing ...
  new-package
];
```

### Add a shell alias

In `home/shared.nix`, append to `programs.zsh.shellAliases`:

```nix
shellAliases = {
  # ... existing ...
  ll = "lsd -la";
};
```

### Add a Homebrew cask

In `modules/darwin/homebrew.nix`, append to `homebrew.casks`. For third-party casks, also add the tap:

```nix
taps = [ "org/tap" ];
casks = [ "org/tap/app" ];
```

### Add a dotfile

Place the file under `home/file/<app>/`, then add a `home.file` entry in `home/shared.nix` (or `home/darwin.nix` for macOS-only):

```nix
home.file."my-config" = {
  target = ".config/app/config.toml";
  source = ./file/app/config.toml;
};
```

### Add an MCP server

In `home/shared.nix`, add to `mcpServers` using the `mkMcpServer` helper:

```nix
"Server Name" = {
  command = mkMcpServer "mcp-server-name" "@org/mcp-pkg@latest";
};
```

The server is automatically deployed to `~/.cursor/mcp.json`, `~/.claude.json`, `~/.gemini/settings.json`, and `~/.codex/config.toml`.

### Apply changes

After editing, the user must run `switch` (alias for `sudo darwin-rebuild switch --flake .#macbook` on macOS). Do **not** run this command as the agent -- inform the user to apply.

# Keep the Claude Code skill catalog in sync

`home/file/agents/CLAUDE.md` contains a skill catalog that makes user-level skills discoverable in Claude Code. When adding, removing, or renaming a skill under `home/file/agents/skills/`, update the corresponding table in `home/file/agents/CLAUDE.md`:

- **Workflow skills**: add/remove a row in the "Workflow skills" table with the `/command`, title (from the `# Title` heading), and `~/.claude/skills/workflows/<name>/SKILL.md` path.
- **Knowledge skills**: add/remove a row in the "Knowledge skills" table with the skill name, title, and `~/.claude/skills/knowledge/<name>/SKILL.md` path.

Apply the catalog update in the same commit as the skill change.

# Evolve new artifacts

Applies when creating or modifying files under `home/file/agents/skills/**/SKILL.md`.

When creating or modifying a skill or subagent prompt in this repository:

- Add a final step that references the **continuous-improvement** skill, e.g.:

```
### N. Evolve

Follow the **continuous-improvement** skill.
```

- For workflow skills that delegate to a shared skill (like `create-work-item`), the shared skill carries the step -- don't duplicate it in the caller.

- Consider whether the artifact benefits from a specific interaction mode (read-only, debug, informational). If it does, add a Step 0 that requires the mode following the **mode-gate** skill.

- Apply the **agent-compatibility** skill to verify the artifact stays portable across agents. Check the portability checklist -- especially if the skill references agent-specific tools or paths.
