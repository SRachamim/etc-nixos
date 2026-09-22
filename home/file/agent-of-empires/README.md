# Agent of Empires repo templates

Copy `config.toml` into each repository that uses AoE:

```sh
mkdir -p .agent-of-empires
cp path/to/etc-nixos/home/file/agent-of-empires/config.toml .agent-of-empires/config.toml
```

## fgrepo monorepo

Register the project once (adjust path to your checkout):

```sh
aoe project add /Volumes/Development/dev.azure.com/fundguard/fgrepo/develop/client
```

Start parallel agent sessions per feature branch:

```sh
aoe add . -w feature/12345-my-feature -b
```

The old Zellij `fg` layout mapped multiple tabs (client, gql-api, webapp, etc.).
With AoE, use separate tmux windows inside a session (`Ctrl+b c`) or multiple
AoE sessions when working across packages in parallel.

## Single-session layout (replaces `ai` Zellij layout)

Inside an AoE session, create panes with stock tmux:

```sh
# After attaching (Enter in AoE TUI):
# Ctrl+b "   — split horizontal (claude top, editor+shell bottom)
# Ctrl+b %   — split vertical (claude left, editor right)
# Ctrl+b %   — split editor pane again for shell
```

Or launch with Claude and open nvim/shell in adjacent panes manually.
