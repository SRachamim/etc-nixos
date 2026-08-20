---
name: nix-shell-direnv-g
description: Detects and uses Nix shell environments via direnv when running commands. Use BEFORE running any shell command -- the skill checks for Nix indicators and adjusts execution accordingly, so it is safe to run even in projects without Nix.
disable-model-invocation: true
---

# Nix Shell Direnv

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
3. **Do not** install packages globally via `npm install -g`, `pip install`, etc. -- the Nix shell provides them

## Examples

```bash
# BAD -- runs outside the Nix environment
npm test

# GOOD -- uses direnv to load the Nix shell
direnv exec . npm test

# GOOD -- fallback without direnv
nix-shell --run "npm test"
nix develop -c npm test
```

## Exceptions

Skip the prefix when the command is read-only git metadata
(e.g., `git status`, `git log`, `git diff`, `git branch`),
file I/O, or unrelated to the project's toolchain
(e.g., `ls`, `mkdir`, `cp`).

**Do NOT skip** for git commands that trigger hooks --
`git commit`, `git merge`, `git rebase`, `git push` --
because hooks typically invoke project toolchain commands
(lint, test, build) that need the Nix shell's PATH and
memory settings.
