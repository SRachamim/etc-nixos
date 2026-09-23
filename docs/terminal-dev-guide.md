# Terminal-Based AI Development Environment Guide

A keyboard-driven, Vim-native development environment optimized for AI agent workflows, managed declaratively through Nix.

> **macOS note:** Throughout this guide, `Alt` means the **Option** key. Ghostty is configured with `macos-option-as-alt = true`, so pressing Option sends Alt to all programs inside the terminal.

> **Full stack reference:** See also [home/file/agent-of-empires/README.md](../home/file/agent-of-empires/README.md) for per-repo AoE setup.

## Architecture Overview

```
AeroSpace (tiling window manager)
  └── Ghostty (terminal emulator)
        ├── Agent of Empires TUI (aoe)
        │     └── tmux session (per agent)
        │           ├── Claude Code (AI agent CLI)
        │           ├── Neovim (editor + claudecode.nvim)
        │           └── Shell (zsh + starship + atuin)
        └── tmux session (workmux, trial)
              └── tmux window (per worktree, created by `wm add`)
                    ├── Claude Code
                    └── Shell
```

AoE gives each agent its own tmux **session** and manages it from its TUI.
workmux gives each agent a **window** inside the session you are already in, and
you manage it from the dashboard (`Ctrl+b g`) or the `wm` CLI.

## Tools Reference

| Tool | Purpose | Config Location |
|------|---------|-----------------|
| AeroSpace | Tiling window manager (macOS) | `home/file/aerospace/aerospace.toml` |
| Ghostty | GPU-accelerated terminal | `home/darwin.nix` (programs.ghostty) |
| tmux | Terminal multiplexer (stock keybinds + 5 plugins) | `home/shared.nix` (programs.tmux) |
| Agent of Empires | Parallel agent session manager | Homebrew `aoe`; repo `.agent-of-empires/config.toml` |
| workmux | Worktree + tmux window per agent (trial, alongside AoE) | Homebrew `workmux`; `home/programs/workmux/` |
| Neovim | Editor | `home/programs/neovim/` |
| Claude Code | AI agent CLI | `home/shared.nix` (home.packages; settings via programs.claude-code) |
| ctx | Per-thread work item / PR / pinned links | `home/file/ctx/ctx.sh` |
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

### Parallel agents with workmux (trial)

workmux is installed next to AoE for evaluation. AoE stays the default. With workmux,
each task gets a worktree and a tmux **window** in the current session, so you
start it from inside tmux:

```bash
wm add feature/12345-my-feature     # worktree at ../feature-12345-my-feature, claude + shell
wm add fix-flaky-login -p "Fix the flaky login test"
wm list                             # worktrees, agent state
wm merge                            # from inside the worktree: merge, then clean up
wm rm fix-flaky-login               # drop without merging
```

- Worktrees land next to `main` (`worktree_dir: ".."`); workmux turns the
  branch's slashes into dashes.
- Tabs show the agent state: working (peach), waiting for input (yellow), done
  (green). Claude Code reports it through hooks in `~/.claude/settings.json`.
- Claude gets upstream's skills: `/workmux`, `/worktree` (fan out tasks),
  `/coordinator` (spawn, monitor and merge agents), `/merge`, `/rebase`,
  `/open-pr`. They are fetched on `switch` from the release that matches the
  installed binary.
- Known quirk: workmux names the project after the main worktree's directory,
  so the dashboard labels every repo `main`.

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

### Per-thread context (files, diffs, panes, pages)

A **thread** is one worktree: one branch, one work item, one PR, one AoE session.
Files, diffs and panes are already grouped by it — two additions group the *pages*.

**Read pages without a browser.** PR threads, work item fields and build logs reach
the agent pane through the Azure DevOps MCP server and the skills that wrap it
(`/review-pr-g`, `/trace-pr-comments-g`, **work-item-context-g**). Text browsers
cannot render ADO's authenticated SPA pages — don't reach for one.

**Bind the browser to the thread with AeroSpace.** Give each active thread a letter
workspace (`A`–`Z`, already persistent in `aerospace.toml`) holding its Ghostty
window and its Chrome window. AeroSpace places a new window in the focused
workspace, so opening Chrome from inside the thread's terminal lands it beside that
terminal. `Alt+<letter>` then switches the whole thread — terminal and pages — at
once. No AeroSpace config change is needed.

**Open the thread's pages with `ctx`.** The work item comes from the branch name
(`feature/12345-slug` → 12345) and the PR from `az repos pr list`, so a fresh
worktree needs no setup.

| Command | Action |
|---------|--------|
| `ctx` | Open work item, PR and pinned links as one browser window in this workspace |
| `ctx wi` / `ctx pr` | Open just the work item / pull request |
| `ctx ls` | List this thread's links |
| `ctx add <name> <url>` | Pin a non-derivable link (dashboard, test run) to this thread |
| `ctx rm <name>` | Unpin a link |

Pinned links live in the worktree's git directory, so they are removed with the
worktree. Set `CTX_BROWSER` to use a browser other than Google Chrome.

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

**Cross-pane (nvim → adjacent tmux pane):** `Ctrl+b` then `h/j/k/l` (bound in `home/shared.nix`; stock tmux only binds the arrow keys).

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
| `Ctrl+b h/j/k/l` | Move between panes (repeatable; `l` replaces stock last-window) |
| `Ctrl+b c` | New window |
| `Ctrl+b n` / `Ctrl+b p` | Next / previous window |
| `Ctrl+b [` | Copy mode (scroll); `q` to exit |
| `Ctrl+b r` | Reload tmux config (replaces stock refresh-client) |
| `Ctrl+b L` | Switch back when nested in AoE-managed tmux |

Plugin and tool bindings. Every one lands on a key stock tmux leaves unbound, so the
default-first principle above still holds — `l` and `r` remain the only shadowed
keys.

| Keys | Plugin | Action |
|------|--------|--------|
| `Ctrl+b Tab` | extrakto | Fuzzy-grab paths, URLs and quoted strings from the pane |
| `Ctrl+b F` | tmux-fzf | Fuzzy switch session / window / pane |
| `Ctrl+b u` | fzf-tmux-url | Pick a URL from the scrollback and open it |
| `Ctrl+b y` | yank | Copy the command line to the system clipboard |
| `Ctrl+b Y` | yank | Copy it and paste it into the pane |
| `y` (copy mode) | yank | Copy the selection to the system clipboard |
| `Ctrl+b Ctrl+s` | resurrect | Save the session layout |
| `Ctrl+b Ctrl+r` | resurrect | Restore the saved layout |
| `Ctrl+b g` | workmux | Dashboard popup (all agents, diffs, jump to one) |
| `Ctrl+b a` | workmux | Jump to the agent that finished or waits for input; repeat to cycle |
| `Ctrl+b A` | workmux | Toggle between the current and the previous agent |
| `Ctrl+b Ctrl+t` | workmux | Toggle the agent status sidebar |

`Ctrl+b Tab` is the one to learn first: it lifts file paths straight out of an
agent's output without touching the mouse.

Sessions are **not** restored automatically. AoE owns session lifecycle;
resurrect only acts when you press the key.

### Mouse

Mouse mode is on. Dragging selects into the tmux buffer and scrolling enters copy
mode. Hold `Option` (or `Shift`) to fall back to Ghostty's own selection when you
want to copy across panes.

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

- Skills: `~/.claude/skills/` (deployed from `home/file/agents/skills/`). workmux's
  six skills land there too; they are fetched on `switch` from the release that
  matches the installed binary, not kept in this repo.
- Settings: `~/.claude/settings.json` is a read-only symlink built by
  `programs.claude-code`. The base keys live in `home/file/claude/settings.json`,
  and modules add their own, such as the workmux status hooks in
  `home/programs/workmux/`. Changes made at runtime with `/config` or `/hooks` do
  not persist.
- Global instructions: `~/.claude/CLAUDE.md`
- MCP: merged into `~/.claude.json`, `~/.cursor/mcp.json`, `~/.gemini/settings.json`, `~/.gemini/config/mcp_config.json` (Antigravity), and `~/.codex/config.toml` on `switch` (Azure DevOps, fundguard, Slack). Use **fundguard** for Datadog and Currents; disable the Cursor **azure** and **datadog** marketplace plugins if they reappear.

### Multi-agent via AoE or workmux

Run multiple Claude Code agents in parallel — each in its own tmux session, optionally on its own worktree. Monitor from the AoE TUI or `aoe serve` web dashboard.

With workmux (trial), each agent gets a worktree and a window in the current
session. Monitor them from the dashboard (`Ctrl+b g`) or the status icons on the
tabs. Inside Claude, `/worktree` fans tasks out to new worktrees and
`/coordinator` spawns, monitors and merges them. See
[Parallel agents with workmux](#parallel-agents-with-workmux-trial).

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

All tools use **Catppuccin Mocha**: Ghostty, Neovim, tmux (via catppuccin home-manager module), Starship, bat, fzf, lsd, workmux.

Flavor lives in three places, because two of them sit outside the catppuccin
home-manager module: `home/shared.nix` (`catppuccin.flavor`, which drives every
Nix-managed tool including Ghostty), `home/programs/neovim/init.lua`
(`flavour` plus the `colorscheme` call), and `home/file/agents/settings.json`
(`workbench.colorTheme`, for Cursor/VS Code). Change all three together.

workmux has no Catppuccin scheme, so `home/programs/workmux/` builds its
dashboard colours and status icons from the catppuccin module's palette
(`catppuccin.flavor` and `catppuccin.accent`). It needs no separate change.

Do **not** set `programs.ghostty.settings.theme` — the catppuccin module already
emits it from `flavor`, and a second definition silently shadows it.

Font: **Fira Code Nerd Font Mono** in Ghostty (`home/darwin.nix`).

The tmux status line sits at the **top** so it never stacks against lualine at the
bottom of a Neovim pane, and its background is transparent to match Neovim's
`transparent_background`. Window tabs use flat separators, mirroring lualine's
empty `component_separators` / `section_separators`. Left shows the session, right
shows the working directory and a 24-hour clock.

tmux declares Ghostty's capabilities explicitly (`terminal-features`): truecolor,
undercurl for LSP diagnostics, synchronized output, OSC 8 hyperlinks, OSC 52
clipboard and CSI-u extended keys. `allow-passthrough` is on, so yazi's image
preview works inside tmux.

## Applying Changes

```bash
switch
```

Rebuilds and activates all configs atomically.

## Troubleshooting

### AoE / tmux

- **`aoe: command not found`:** run `switch` (installs Homebrew `aoe` and a Nix profile wrapper). Open a new shell or run `exec zsh`. Verify with `which aoe` — should point to the home-manager profile, not only `/opt/homebrew/bin`.
- **Launch AoE from a plain Ghostty tab**, not from inside an AoE tmux session (nested tmux: `Ctrl+b L` to switch back).
- **Pane nav:** confirm `Ctrl+b` prefix before `h/j/k/l`.
- **tmux change didn't take effect:** a running tmux server loads its config only at server start. `Ctrl+b r` re-sources it, which covers `set -g` options and keybindings. Changes to `default-terminal` or to the plugin list need a full `tmux kill-server` (this drops running sessions — detach AoE work first).
- **Session orphaned:** delete from AoE TUI (`d`); AoE-created worktrees are cleaned on delete.

### workmux

- **`workmux: not installed — run switch`:** the profile wrapper found no
  Homebrew binary. Run `switch`; Homebrew installs and upgrades `workmux` on every
  run.
- **No `/workmux` or `/worktree` skill:** skills are fetched after the binary
  exists, so the first `switch` that installs workmux may have skipped them. Run
  `switch` again (it needs network access to GitHub).
- **No status icon on the tab:** the icon comes from the catppuccin window text.
  Run `Ctrl+b r` to re-source tmux, then start a new `claude` session so it picks
  up the hooks.
- **Hooks drifted from upstream:** run `workmux setup --hooks` in a terminal. It
  reports "update available" if upstream changed them. Decline the write and
  update `home/programs/workmux/default.nix` instead.
- **No `wm <Tab>` completion:** Homebrew completions load from
  `/opt/homebrew/share/zsh/site-functions`; open a new shell after `switch`.

### ctx

- **`origin is not an Azure DevOps remote`:** links are derived from `origin`; ADO SSH and HTTPS remotes are supported.
- **`branch … carries no work item id`:** name branches `feature/<id>-<slug>` per **worktree-layout-g**, or pin the link with `ctx add`.
- **`no active pull request`:** the PR is not open yet, or `az` is not signed in — run `az login`.

### Neovim ↔ Claude Code

`claudecode.nvim` uses a WebSocket Claude auto-detects. Ensure nvim runs before Claude in the same tmux session.

### Neovim LSP

Language servers must be in `$PATH`. TypeScript: `volta install typescript-language-server`. Nix: `nil`. Bash: `bash-language-server`.

### Crossing nvim → tmux pane

Use `Ctrl+b h/j/k/l` (bound in `home/shared.nix`) or `Ctrl+b` plus an arrow key. No bridge plugin — `vim-tmux-navigator` stays deliberately unadopted, because binding bare `Ctrl+h/j/k/l` would take those keys away from the focused app. Revisit only if prefix discipline proves too slow in daily use.

### Theme inconsistencies

Run `switch` to re-apply Catppuccin across all supported programs.
