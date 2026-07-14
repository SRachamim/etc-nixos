---
globs: home/darwin.nix, home/shared.nix, home/nixos.nix, home/programs/neovim/**, home/file/zellij/**, home/file/aerospace/**, home/file/ghostty/**, overlays/default.nix
---

When modifying these configuration files, check whether `docs/terminal-dev-guide.md` needs a corresponding update. Changes that require a guide update include: keybinding additions/removals/remappings, new or removed plugins, new or removed tools and shell aliases, navigation hierarchy changes, and theme or font changes. Apply the guide update in the same commit.
