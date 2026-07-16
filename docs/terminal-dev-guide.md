# Terminal-Based AI Development Environment Guide

A keyboard-driven, Vim-native development environment optimized for AI agent workflows, managed declaratively through Nix.

> **macOS note:** Throughout this guide, `Alt` means the **Option** key. Ghostty is configured with `macos-option-as-alt = true`, so pressing Option sends Alt to all programs inside the terminal.

## Architecture Overview

```
Ghostty (terminal emulator)
  └── Zellij (terminal multiplexer)
        ├── Neovim (editor)
        │     ├── claudecode.nvim  (send code to Claude Code)
        │     ├── avante.nvim      (Cursor-like AI panel)
        │     ├── lazygit.nvim     (git TUI)
        │     └── native LSP + telescope + treesitter
        ├── Claude Code (AI agent CLI)
        └── Shell (zsh + starship + atuin)
```

## Tools Reference

| Tool | Purpose | Config Location |
|------|---------|-----------------|
| AeroSpace | Tiling window manager (macOS) | `home/file/aerospace/aerospace.toml` |
| Ghostty | GPU-accelerated terminal | `home/darwin.nix` (programs.ghostty) |
| Zellij | Terminal multiplexer | `home/shared.nix` (programs.zellij) |
| Neovim | Editor | `home/programs/neovim/` |
| Claude Code | AI agent CLI | `home/shared.nix` (home.packages) |
| Starship | Shell prompt | `home/shared.nix` (programs.starship) |
| Atuin | Shell history with fuzzy search | `home/shared.nix` (programs.atuin) |
| lazygit | Git TUI | `home/shared.nix` (programs.lazygit) |
| yazi | File manager TUI | `home/shared.nix` (programs.yazi) |
| btop | System monitor TUI | `home/shared.nix` (programs.btop) |
| lazydocker | Docker TUI | `home/shared.nix` (home.packages) |
| workmux | Git worktree + multiplexer orchestrator | `modules/darwin/homebrew.nix` |
| Catppuccin Mocha | Color theme (all tools) | `home/shared.nix` (catppuccin module) |
| Fira Code Nerd Font | Primary font | `home/shared.nix` (home.packages) |

## Getting Started

### 1. Apply the Configuration

After cloning this repository:

```bash
cd /Volumes/Development/github.com/srachamim/etc-nixos/main
switch   # alias for: sudo darwin-rebuild switch --flake .#macbook
```

### 2. Launch the AI Workspace

```bash
ai   # alias for: zellij --layout ai
```

This opens a Zellij session with three panes:
- **Left (50%)**: Claude Code agent
- **Top-right (70%)**: Neovim editor
- **Bottom-right**: Shell

### 3. Navigate Between Panes

Use `Ctrl+h/j/k/l` everywhere. This single set of keys navigates Zellij panes, Neovim splits, and the boundary between them seamlessly. See the [Navigation Hierarchy](#navigation-hierarchy) section for details.

## Navigation Hierarchy

Four layers process every keypress. Each layer owns a specific modifier to avoid conflicts:

```
Keypress (Ctrl+h)
  │
  ├── Layer 1: AeroSpace (macOS tiling WM)
  │     Owns: Alt+h/j/k/l → focus adjacent OS window
  │     Ctrl+h/j/k/l passes through
  │
  ├── Layer 2: Ghostty (terminal emulator)
  │     No split keybinds — all keys pass through to Zellij
  │
  ├── Layer 3: Zellij (multiplexer)
  │     Normal mode: Ctrl+h/j/k/l → navigate Zellij panes
  │     Locked mode: passes through to the focused program
  │
  └── Layer 4: Neovim / Claude Code / shell
        Neovim: Ctrl+h/j/k/l → navigate Vim splits;
                at the edge, zellij.vim jumps to the adjacent Zellij pane
        Claude Code / shell: Zellij auto-locks, so Ctrl keys reach the app
```

### How autolock works

The `zellij-autolock` plugin watches the command running in each Zellij pane. When you focus a pane running Neovim, Claude Code, lazygit, fzf, or atuin, Zellij automatically switches to **Locked** mode -- letting all keybindings pass through to the application. When you switch to a plain shell pane, Zellij returns to **Normal** mode.

You can manually toggle the lock with `Alt+z`.

### Zellij keybinding reference

| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+h/j/k/l` | Normal | Navigate panes |
| `Alt+z` | Any | Toggle autolock (manual lock/unlock) |
| `Alt+Shift+f` | Normal | Toggle floating panes |
| `Alt+Shift+n` | Normal | New tab |
| `Ctrl+Shift+o` | Normal | Session mode |
| `Ctrl+y` | Normal | Keybinding cheatsheet (zellij-forgot) |
| `Alt+[/]` | Normal | Switch tabs |
| `Alt+n` | Normal | New pane |
| `Ctrl+p` | Normal | Pane mode (resize etc.) |

### Zellij plugins

| Plugin | Purpose | Trigger |
|--------|---------|---------|
| `zellij-autolock` | Auto-lock/unlock based on focused command | Background (always running) |
| `zellij-forgot` | Searchable keybinding cheatsheet | `Ctrl+y` |

## Neovim Keybindings

### Navigation (Telescope)

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

Inside Telescope:
- `Ctrl+j/k` - Move up/down in results
- `Enter` - Open selection
- `Ctrl+x` - Open in horizontal split
- `Ctrl+v` - Open in vertical split
- `Esc` - Close

### LSP (Code Intelligence)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gy` | Go to type definition |
| `gi` | Go to implementation |
| `gr` | Show references |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>f` | Format (normal/visual) |
| `[g` / `]g` | Previous/next diagnostic |
| `<leader>e` | Line diagnostics |
| `<leader>q` | Diagnostics to location list |

### Claude Code Integration (claudecode.nvim)

| Key | Action |
|-----|--------|
| `<leader>ac` | Toggle Claude Code terminal |
| `<leader>af` | Focus Claude Code |
| `<leader>as` | Send visual selection to Claude (like Cmd+L in Cursor) |
| `<leader>ab` | Add current buffer to Claude context |

This is the terminal equivalent of Cursor's Cmd+L:
1. Visual-select code in Neovim
2. Press `<leader>as`
3. The selection is sent to the Claude Code split

### Avante.nvim (Cursor-like AI Panel)

| Key | Action |
|-----|--------|
| `<leader>aa` | Ask AI about code |
| `<leader>ae` | Edit code with AI |
| `<leader>ar` | Refresh AI response |

Avante provides an in-editor AI panel (like Cursor's sidebar). Select code, press `<leader>aa`, type an instruction, and get a diff to accept/reject.

### Git (lazygit + diffview)

| Key | Action |
|-----|--------|
| `<leader>lg` | Open LazyGit |
| `<leader>gd` | Open diff view |
| `<leader>gh` | File history |
| `<leader>gc` | Close diff view |

### Utility

| Key | Action |
|-----|--------|
| `<leader>yp` | Yank `filepath:line` to clipboard (normal mode) |
| `<leader>yp` | Yank `filepath:startline-endline` to clipboard (visual mode) |
| `<leader>l` | Clear search highlight + redraw |

The yank-path binding is useful for pasting file references into Claude Code's chat.

## Claude Code

### Vim Mode

Claude Code's input area supports Vim keybindings. Press `Esc` in the input to enter normal mode, use standard Vim motions to edit your prompt.

### Key Commands

| Command | Action |
|---------|--------|
| `/help` | Show all commands |
| `/compact` | Summarize and compact conversation |
| `/clear` | Clear conversation history |
| `/model` | Switch AI model |
| `/vim` | Toggle vim mode |
| `/cost` | Show token usage |

### Multi-Agent Workflows

Claude Code has built-in multi-agent support:

```bash
claude agents
```

This opens Agent View where you can:
- Launch multiple agents that work in parallel on different tasks
- Each agent gets its own git worktree automatically
- Monitor progress of all agents from a single dashboard
- Approve/reject changes before merging

### Skills and Hooks

Claude Code can be extended with skills (reusable prompt templates) and hooks (event-driven automations). These are configured in:
- `~/.claude/skills/` - Skill definitions
- `~/.claude/CLAUDE.md` - Global instructions
- Project-level `CLAUDE.md` files

## Workmux (Parallel Development)

workmux creates isolated development environments per git branch using worktrees + multiplexer windows.

### Quick Start

```bash
# Create a new branch + worktree + Zellij tab
workmux add feature-branch

# List active worktrees
workmux list

# Switch to an existing worktree
workmux switch feature-branch

# Remove a worktree and its window
workmux remove feature-branch
```

### With Claude Agents

Combine workmux with Claude Code for parallel AI-driven development:

```bash
# Terminal 1: Work on feature A
workmux add feature-a
claude "Implement feature A based on the spec in docs/feature-a.md"

# Terminal 2: Work on feature B
workmux add feature-b
claude "Implement feature B based on the spec in docs/feature-b.md"
```

Each agent works in its own worktree, so there are no merge conflicts during development.

## Atuin (Shell History)

Atuin replaces the default shell history with a searchable database.

| Key | Action |
|-----|--------|
| `Ctrl+r` | Search all history (fuzzy) |
| `Up arrow` | Search current session history |

Search is fuzzy by default. Type partial commands and Atuin filters results.

## Zellij Layouts

### AI Layout (`ai`)

```bash
ai   # alias
```

Three-pane layout: Claude Code | Neovim + Shell

### FGRepo Layout (`fg`)

```bash
fg   # alias
```

Multi-tab layout for the fgrepo project.

### Custom Layouts

Create new layouts in `home/file/zellij/layouts/` as KDL files. Register them in `home/shared.nix` under `home.file` and add a shell alias.

### Zellij Plugins & Keybinding Config

Plugin definitions and keybinding overrides live in `programs.zellij.extraConfig` in `home/shared.nix`. The `plugins {}` block defines plugin aliases, `load_plugins {}` starts background plugins, and `keybinds {}` configures per-mode key bindings.

To add autolock triggers for a new TUI tool, find the `triggers` line in the autolock plugin config and append the command name (pipe-separated).

## TUI Tools

### lazygit

Full git TUI with staging, committing, branching, rebasing, and more.

Launch: `lazygit` in shell or `<leader>lg` in Neovim.

Key areas:
- **Files panel** (1): Stage/unstage files, view diffs
- **Branches panel** (2): Create, checkout, merge, rebase
- **Commits panel** (3): Amend, squash, reorder, cherry-pick
- **Stash panel** (4): Stash and pop changes

Navigation: `h/j/k/l` between panels and items, `Enter` to expand, `Space` to stage, `c` to commit.

### yazi

Terminal file manager with Vim keybindings.

Launch: `yazi` in shell.

Key bindings: `h/j/k/l` navigate, `Enter` open, `q` quit, `Space` select, `d` delete, `r` rename, `p` paste, `y` copy.

### btop

System monitor showing CPU, memory, network, disk, and processes.

Launch: `btop` in shell.

### lazydocker

Docker container/image/volume manager TUI.

Launch: `lazydocker` in shell.

## Theming

All tools use **Catppuccin Mocha** consistently:

| Tool | How Applied |
|------|-------------|
| Ghostty | `programs.ghostty` (auto-enabled by catppuccin module) |
| Neovim | `catppuccin-nvim` plugin + `colorscheme catppuccin-mocha` |
| Zellij | `theme = "catppuccin-mocha"` |
| Starship | catppuccin module auto-enable |
| bat | catppuccin module auto-enable |
| fzf | catppuccin module auto-enable |
| lsd | catppuccin module auto-enable |
| lazygit | Follows terminal colors |
| btop | Follows terminal colors |

The Catppuccin home-manager module (`catppuccin.enable = true; catppuccin.flavor = "mocha"`) auto-applies the theme to all supported programs.

## Font

**Fira Code Nerd Font Mono** is the primary font set in Ghostty. JetBrains Mono Nerd Font is also installed as an alternative.

To switch: edit `programs.ghostty.settings.font-family` in `home/darwin.nix`.

## Applying Changes

After editing any Nix file in this repository:

```bash
switch
```

This rebuilds the entire system configuration and activates it. All tool configs, packages, fonts, and themes are applied atomically.

## Troubleshooting

### Neovim LSP not starting

Ensure language servers are installed. The LSP config expects servers to be available in `$PATH`. For TypeScript: `volta install typescript-language-server`. For Nix: `nix profile install nixpkgs#nil`. For Bash: `nix profile install nixpkgs#bash-language-server`.

### Claude Code not connecting to Neovim

`claudecode.nvim` starts a WebSocket server that Claude Code auto-detects. Ensure:
1. Neovim is running before launching Claude Code
2. Both are in the same terminal session (Zellij/Ghostty)
3. The `NVIM` environment variable is set (should be automatic)

### Pane navigation not working

Ghostty does not have its own split keybindings -- all pane management is done by Zellij. If `Ctrl+h/j/k/l` isn't working:
1. Check that `zellij-autolock` is loaded (`Ctrl+y` to open the keybinding cheatsheet).
2. If stuck in Locked mode, press `Alt+z` to manually unlock.
3. If Neovim is focused and `Ctrl+h/j/k/l` isn't crossing to a Zellij pane, ensure `zellij.vim` is loaded (`:checkhealth` in Neovim).

### Theme inconsistencies

Run `switch` to re-apply the full configuration. The Catppuccin module handles theme consistency across all supported tools.
