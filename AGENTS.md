# Declarative Nix only

Every change to packages, services, programs, dotfiles, environment variables, shell aliases, fonts, or system settings **must** be made declaratively in this repository. Never perform or suggest imperative mutations that won't survive `nixos-rebuild switch`, `home-manager switch`, or porting to a new machine.

## Banned imperative patterns

- `brew install` / `brew cask install`
- `apt install` / `dnf install` / `pacman -S`
- `npm install -g` / `pip install --user`
- `defaults write` / `gsettings set`
- `systemctl enable` / `launchctl load`
- Manually editing config files outside this repo (e.g. `~/.zshrc`, `~/.gitconfig`)

## Where to make changes

| Change type | File(s) |
|-------------|---------|
| NixOS system packages | `environment.nix` |
| home-manager packages / programs | `home.nix` |
| Shell config (zsh) | `home/programs/.zshrc` |
| Dotfiles (ghostty, aerospace, zellij, etc.) | `home/file/<app>/` |
| Agent artifacts (skills, subagents, rules) | `home/file/agents/` |
| Neovim config | `home/programs/neovim/` |
| Fonts | `fonts.nix` |
| Services | `services.nix` |
| Networking | `networking.nix` |

Do **not** edit `hardware-configuration.nix` -- it is auto-generated.

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
