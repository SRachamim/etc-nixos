{ config, pkgs, lib, ... }:
let
  cursorCli = "/Applications/Cursor.app/Contents/Resources/app/bin/cursor";

  cursorExtensions = [
    "asvetliakov.vscode-neovim"
    "catppuccin.catppuccin-vsc"
    "catppuccin.catppuccin-vsc-icons"
    "catppuccin.catppuccin-vsc-pack"
    "dbaeumer.vscode-eslint"
    "eamodio.gitlens"
    "jnoortheen.nix-ide"
    "luksch42.themetree"
    "mermaidchart.vscode-mermaid-chart"
    "ms-python.python"
    "ms-python.debugpy"
    "redhat.java"
    "shiftspace.shiftspace"
    "tamasfe.even-better-toml"
    "xadillax.viml"
    "vscjava.vscode-java-pack"
  ];
in
{
  home.username = "sahar.rachamim";
  home.homeDirectory = "/Users/sahar.rachamim";

  home.sessionPath = [
    "/Applications/Cursor.app/Contents/Resources/app/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
  ];

  # Homebrew binaries are not on the Nix-managed PATH by default. The wrapper
  # lands in the home-manager profile (already on PATH); sessionPath covers
  # other brew tools after a new login shell.
  home.packages = [
    (pkgs.writeShellApplication {
      name = "aoe";
      text = ''
        aoe_bin=/opt/homebrew/bin/aoe
        if [ ! -x "$aoe_bin" ]; then
          echo "aoe: not installed — run switch to install via Homebrew" >&2
          exit 127
        fi
        exec "$aoe_bin" "$@"
      '';
    })
  ];

  programs.zsh.initContent = lib.mkOrder 50 ''
    path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
  '';

  home.file = {
    "aerospace-config" = {
      source = ./file/aerospace/aerospace.toml;
      target = ".aerospace.toml";
    };
    "cursor-settings" = {
      target = "Library/Application Support/Cursor/User/settings.json";
      source = ./file/agents/settings.json;
      force = true;
    };
    "catppuccin-wallpaper" = {
      source = ./file/wallpaper/catppuccin-mocha.png;
      target = ".local/share/wallpaper/catppuccin-mocha.png";
    };
  };

  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      font-family = "FiraCode Nerd Font Mono";
      macos-option-as-alt = true;
      macos-titlebar-style = "hidden";
      shell-integration = "zsh";
      window-padding-balance = true;
      keybind = [
        "alt+left=unbind"
        "alt+right=unbind"
      ];
    };
  };

  home.activation.setWallpaper = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    /usr/bin/osascript -e '
      tell application "System Events"
        tell every desktop
          set picture to "'$HOME'/.local/share/wallpaper/catppuccin-mocha.png"
        end tell
      end tell
    ' 2>/dev/null || true
  '';

  home.activation.reloadAerospace = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if /usr/bin/pgrep -q AeroSpace 2>/dev/null; then
      /opt/homebrew/bin/aerospace reload-config 2>/dev/null || true
    fi
  '';

  home.activation.installCursorExtensions = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if [ -x "${cursorCli}" ]; then
      echo "Installing Cursor extensions..." >&2
      ${lib.concatMapStringsSep "\n" (ext: ''
        "${cursorCli}" --install-extension "${ext}" --force 2>/dev/null || true
      '') cursorExtensions}
    fi
  '';

  # Azure DevOps is covered by the user MCP; azure/datadog marketplace plugins
  # duplicate or conflict (npx missing from Cursor PATH; cloud Datadog needs OAuth).
  # Datadog and Currents are available via the fundguard proxy. CLI disable alone
  # does not stop the IDE from loading plugin MCP — neutralize configs and uninstall.
  home.activation.disableCursorPluginMcps = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    PLUGIN_CACHE="$HOME/.cursor/plugins/cache/cursor-public"
    EMPTY_MCP='{"mcpServers":{}}'

    for f in "$PLUGIN_CACHE"/azure/*/.mcp.json; do
      [ -f "$f" ] && printf '%s\n' "$EMPTY_MCP" > "$f"
    done
    for f in "$PLUGIN_CACHE"/datadog/*/.dd_cursor_mcp.json; do
      [ -f "$f" ] && printf '%s\n' "$EMPTY_MCP" > "$f"
    done
    for f in \
      "$PLUGIN_CACHE"/azure/*/.cursor-plugin/plugin.json \
      "$PLUGIN_CACHE"/datadog/*/.cursor-plugin/plugin.json; do
      if [ -f "$f" ]; then
        ${pkgs.jq}/bin/jq 'del(.mcpServers)' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
      fi
    done

    STATE_DB="$HOME/Library/Application Support/Cursor/User/globalStorage/state.vscdb"
    if [ -f "$STATE_DB" ]; then
      while IFS= read -r pluginKey; do
        [ -n "$pluginKey" ] || continue
        current=$(${pkgs.sqlite}/bin/sqlite3 "$STATE_DB" "SELECT value FROM ItemTable WHERE key = '$pluginKey';")
        filtered=$(${pkgs.jq}/bin/jq -c '[.[] | select(.id != "1411" and .id != "6392")]' <<< "$current")
        if [ "$current" != "$filtered" ]; then
          ${pkgs.sqlite}/bin/sqlite3 "$STATE_DB" "UPDATE ItemTable SET value = '$filtered' WHERE key = '$pluginKey';"
        fi
      done < <(${pkgs.sqlite}/bin/sqlite3 "$STATE_DB" "SELECT key FROM ItemTable WHERE key LIKE 'cursor.plugins.installedIds.%';")

      disabledCurrent=$(${pkgs.sqlite}/bin/sqlite3 "$STATE_DB" "SELECT value FROM ItemTable WHERE key = 'cursor/disabledGlobalMcpServers';")
      disabledMerged=$(${pkgs.jq}/bin/jq -c '. + ["plugin-azure-azure","plugin-datadog-datadog"] | unique' <<< "''${disabledCurrent:-[]}")
      ${pkgs.sqlite}/bin/sqlite3 "$STATE_DB" "INSERT OR REPLACE INTO ItemTable (key, value) VALUES ('cursor/disabledGlobalMcpServers', '$disabledMerged');"
    fi

    if [ -x "${cursorCli}" ]; then
      for id in plugin-azure-azure plugin-datadog-datadog; do
        "${cursorCli}" agent mcp disable "$id" 2>/dev/null || true
      done
    fi
  '';
}
