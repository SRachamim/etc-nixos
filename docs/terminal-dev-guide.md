# Terminal-Based AI Development Environment Guide

A keyboard-driven, Vim-native development environment optimized for AI agent workflows, managed declaratively through Nix.

> **macOS note:** Throughout this guide, `Alt` means the **Option** key. Ghostty is configured with `macos-option-as-alt = true`, so pressing Option sends Alt to all programs inside the terminal.

> **Full stack reference:** See also [home/file/agent-of-empires/README.md](../home/file/agent-of-empires/README.md) for per-repo AoE setup.

## Architecture Overview

```
AeroSpace (tiling window manager)
  └── Ghostty (terminal emulator)
        └── Agent of Empires TUI (aoe)
              └── tmux session (per agent)
                    ├── Claude Code (AI agent CLI)
                    ├── Neovim (editor + claudecode.nvim)
                    └── Shell (zsh + starship + atuin)
```

## Tools Reference

| Tool | Purpose | Config Location |
|------|---------|-----------------|
| AeroSpace | Tiling window manager (macOS) | `home/file/aerospace/aerospace.toml` |
| Ghostty | GPU-accelerated terminal | `home/darwin.nix` (programs.ghostty) |
| tmux | Terminal multiplexer (stock keybinds) | `home/shared.nix` (programs.tmux) |
| Agent of Empires | Parallel agent session manager | Homebrew `aoe`; repo `.agent-of-empires/config.toml` |
| Neovim | Editor | `home/programs/neovim/` |
| Claude Code | AI agent CLI | `home/shared.nix` (home.packages) |
| Starship | Shell prompt | `home/shared.nix` (programs.starship) |
| Atuin | Shell history with fuzzy search | `home/shared.nix` (programs.atuin) |
| lazygit | Git TUI | `home/shared.nix` (programs.lazygit) |
| yazi | File manager TUI | `home/shared.nix` (programs.yazi) |
| btop | System monitor TUI | `home/shared.nix` (programs.btop) |
| lazydocker | Docker TUI | `home/shared.nix` (home.packages) |
| Catppuccin Mocha | Color theme (all tools) | `home/shared.nix` (catppuccin module) |
| Fira Code Nerd Font | Primary font | `home/shared.nix` (home.packages) |

## Getting Started

### 1. Apply the Configuration

After cloning this repository:

```bash
cd /Volumes/Development/github.com/srachamim/etc-nixos/main
switch   # alias for: sudo darwin-rebuild switch --flake .#macbook
```

### 2. Launch Agent of Empires

```bash
aoe
```

Press `?` in the TUI for the full keymap.

### 3. Create Your First Session

From a project directory:

```bash
aoe add --cmd claude .
```

Or from the AoE TUI: press `n`, set the path, select Claude as the agent.

### 4. Attach and Detach

- **Attach:** select session in AoE TUI, press `Enter`
- **Detach:** inside the tmux session, press `Ctrl+b` then `d`
- Sessions persist when you quit the AoE TUI or close Ghostty

## Daily Workflows

### Single-session vim + Claude Code

1. `aoe add --cmd claude .` (or attach to an existing session)
2. Split panes with stock tmux (`Ctrl+b %`, `Ctrl+b "`) — Claude, nvim, shell
3. Edit in nvim; send selections with `<leader>as` (see claudecode.nvim below)
4. `Ctrl+b d` to detach; `aoe` to reattach later

### Parallel multi-agent development

One AoE session per branch/work item:

```bash
aoe add . -w feature/12345-my-feature -b
aoe add . -w feature/67890-other-fix -b
```

Monitor all sessions from the AoE TUI. Press `D` for diff review across agents.

Optional web dashboard:

```bash
aoe serve              # localhost
aoe serve --remote     # reachable from phone/browser (use with care)
```

### ADO-driven work (skills + AoE)

Use **`/checkout-worktree-g`** when you need Azure DevOps work-item metadata, branch naming (`feature/<id>-<slug>`), and activation — it creates the git worktree per **worktree-layout-g**.

Then start an AoE session in that worktree:

```bash
cd /path/to/repo/feature/12345-my-feature
aoe add --cmd claude .
```

Or combine worktree creation with AoE directly when you already know the branch name:

```bash
aoe add . -w feature/12345-my-feature -b
```

Use **`/close-worktree-g`** after merge for ADO verification and git cleanup. Delete the AoE session from the TUI (`d`) when done — AoE cleans up worktrees it created.

### fgrepo monorepo

Register once:

```bash
aoe project add /Volumes/Development/dev.azure.com/fundguard/fgrepo/develop/client
```

Press `b` in the AoE TUI to start sessions from saved projects. See `home/file/agent-of-empires/README.md`.

## Keybinding Philosophy (default-first)

**Principle:** Use each tool's **stock, documented keybindings**. Customize only when two layers would bind the same key to different actions. Cosmetic config (themes, fonts) is fine; keybind overrides are not.

### Layer ownership

| Layer | Modifier / pattern | Owns |
|-------|-------------------|------|
| AeroSpace | `Alt+*` | macOS window/workspace tiling |
| Ghostty | (none for splits) | Terminal rendering; passes keys through |
| tmux | `Ctrl+b` prefix, then key | Pane/window/session management |
| AoE TUI | `n`, `Enter`, `?`, etc. | Session dashboard (outside agent sessions) |
| Neovim | `<leader>*`, `gd`, `Ctrl+w h/j/k/l` | Editor, LSP, Telescope |
| Claude Code | `/commands`, vim mode in input | Agent chat |
| TUIs (lazygit, fzf, atuin) | Each app's defaults | Git, search, history |

### Why prefix discipline works

tmux only acts **after** the `Ctrl+b` prefix. Bare `Ctrl+h/j/k/l` reach Neovim for split navigation. Bare `Ctrl+n/p` reach Telescope in pickers. No bridge plugin required.

**Cross-pane (nvim → adjacent tmux pane):** `Ctrl+b` then `h/j/k/l` (stock tmux).

### Navigation flow

```
Keypress
  ├── Alt held?        → AeroSpace (workspaces, windows)
  ├── Ctrl+b prefix?   → tmux (panes, windows, detach)
  └── otherwise        → focused app (nvim, Claude, lazygit, shell, …)
```

## Keybinding Reference

### tmux (prefix `Ctrl+b`)

| Keys | Action |
|------|--------|
| `Ctrl+b d` | Detach from session |
| `Ctrl+b %` | Split vertical |
| `Ctrl+b "` | Split horizontal |
| `Ctrl+b h/j/k/l` | Move between panes |
| `Ctrl+b c` | New window |
| `Ctrl+b n` / `Ctrl+b p` | Next / previous window |
| `Ctrl+b [` | Copy mode (scroll); `q` to exit |
| `Ctrl+b L` | Switch back when nested in AoE-managed tmux |

### AoE TUI

| Key | Action |
|-----|--------|
| `n` | New session |
| `b` | New session from saved project |
| `Enter` | Attach to session |
| `d` | Delete session |
| `t` | Toggle agent / terminal view |
| `D` | Diff view |
| `/` | Search sessions |
| `?` | Help |
| `q` | Quit TUI |

### Neovim — Navigation (Telescope)

| Key | Action |
|-----|--------|
| `<leader>p` | Find files |
| `<leader>g` | Live grep (ripgrep) |
| `<leader>b` | Switch buffer |
| `<leader>h` | Recent files |
| `<leader>T` | Tags |
| `<leader>t` | Buffer tags |
| `<leader>d` | Diagnostics list |
| `<leader>s` | Document symbols |

Inside Telescope: `Ctrl+j/k`, `Ctrl+n/p`, `Enter`, `Ctrl+x/v`, `Esc` — all stock; tmux does not intercept bare Ctrl keys.

### Neovim — LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gy` | Go to type definition |
| `gi` | Go to implementation |
| `gr` | Show references |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>f` | Format |
| `[g` / `]g` | Previous/next diagnostic |
| `<leader>e` | Line diagnostics |
| `<leader>q` | Diagnostics to location list |

### Neovim — Claude Code (claudecode.nvim)

| Key | Action |
|-----|--------|
| `<leader>ac` | Toggle Claude Code terminal |
| `<leader>af` | Focus Claude Code |
| `<leader>as` | Send visual selection to Claude |
| `<leader>ab` | Add current buffer to Claude context |

Workflow: visual-select code → `<leader>as` → selection sent to Claude Code split.

### Neovim — Git

| Key | Action |
|-----|--------|
| `<leader>lg` | Open LazyGit |
| `<leader>gd` | Open diff view |
| `<leader>gh` | File history |
| `<leader>gc` | Close diff view |

### Neovim — Utility

| Key | Action |
|-----|--------|
| `<leader>yp` | Yank `filepath:line` (normal) or range (visual) |
| `<leader>l` | Clear search highlight + redraw |

### AeroSpace

See `home/file/aerospace/aerospace.toml` — `Alt+h/j/k/l` focus, `Alt+1–9` workspaces, `Alt+Shift+…` move windows.

## Claude Code

### Vim mode

Press `Esc` in the input for normal mode; standard Vim motions edit your prompt. Toggle with `/vim`.

### Key commands

| Command | Action |
|---------|--------|
| `/help` | Show all commands |
| `/compact` | Summarize conversation |
| `/clear` | Clear history |
| `/model` | Switch model |
| `/resume` | Resume prior conversation (AoE persists session id) |
| `/cost` | Token usage |

### Skills and MCP

- Skills: `~/.claude/skills/` (deployed from `home/file/agents/skills/`)
- Global instructions: `~/.claude/CLAUDE.md`
- MCP: merged into `~/.claude.json` on `switch` (Azure DevOps, FundGuard, Slack)

### Multi-agent via AoE

Run multiple Claude Code agents in parallel — each in its own tmux session, optionally on its own worktree. Monitor from the AoE TUI or `aoe serve` web dashboard.

## TUI Tools

### lazygit

Launch: `lazygit` or `<leader>lg`. Navigation: `h/j/k/l`, `Enter`, `Space`, `c`.

### yazi

Launch: `y` or `yazi`. Navigation: `h/j/k/l`, `Enter`, `q`, `Space`, `d`, `r`, `p`, `y`.

### btop / lazydocker

Launch: `btop` / `lazydocker` in shell.

## Atuin (Shell History)

| Key | Action |
|-----|--------|
| `Ctrl+r` | Fuzzy search all history |
| `Up arrow` | Search current session |

## Theming

All tools use **Catppuccin Mocha**: Ghostty, Neovim, tmux (via catppuccin home-manager module), Starship, bat, fzf, lsd.

Font: **Fira Code Nerd Font Mono** in Ghostty (`home/darwin.nix`).

## Applying Changes

```bash
switch
```

Rebuilds and activates all configs atomically.

## Troubleshooting

### AoE / tmux

- **Launch AoE from a plain Ghostty tab**, not from inside an AoE tmux session (nested tmux: `Ctrl+b L` to switch back).
- **Pane nav:** confirm `Ctrl+b` prefix before `h/j/k/l`.
- **Session orphaned:** delete from AoE TUI (`d`); AoE-created worktrees are cleaned on delete.

### Neovim ↔ Claude Code

`claudecode.nvim` uses a WebSocket Claude auto-detects. Ensure nvim runs before Claude in the same tmux session.

### Neovim LSP

Language servers must be in `$PATH`. TypeScript: `volta install typescript-language-server`. Nix: `nil`. Bash: `bash-language-server`.

### Crossing nvim → tmux pane

Use `Ctrl+b h/j/k/l` (stock tmux). No bridge plugin in v1. If too slow after daily use, consider adding `vim-tmux-navigator` as a documented exception.

### Theme inconsistencies

Run `switch` to re-apply Catppuccin across all supported programs.
