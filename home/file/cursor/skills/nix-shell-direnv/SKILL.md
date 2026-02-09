---
name: nix-shell-direnv
description: Detect and use Nix shell environments via direnv when running commands. Use whenever the agent runs shell commands in a project that may have a Nix shell or direnv environment.
---

# Nix Shell / direnv Awareness

When running shell commands in a project, check for a Nix shell environment first.

## Detection

Before executing commands, look for these indicators:

- `.envrc` containing `use nix`, `use flake`, or `nix-shell`
- `shell.nix` or `default.nix` in the project root
- `flake.nix` with a `devShells` output

## Behavior

If a Nix shell environment is detected:

1. **Prefix commands** with `direnv exec .` to ensure the environment is loaded
2. If `direnv` is unavailable, fall back to `nix-shell --run "<command>"` or `nix develop -c <command>`
3. **Do not** install packages globally via `npm install -g`, `pip install`, etc. — the Nix shell provides them

## Examples

```bash
# BAD — runs outside the Nix environment
npm test

# GOOD — uses direnv to load the Nix shell
direnv exec . npm test

# GOOD — fallback without direnv
nix-shell --run "npm test"
nix develop -c npm test
```

## Exceptions

Skip the prefix when the command is purely git, file I/O, or unrelated to the project's toolchain (e.g., `git status`, `ls`, `mkdir`).
