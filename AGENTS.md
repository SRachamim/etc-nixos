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

Do **not** edit `hosts/nixos/hardware-configuration.nix` -- it is auto-generated.

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
