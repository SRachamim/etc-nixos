{ config, pkgs, lib, ... }:
let
  cursorCli = "/Applications/Cursor.app/Contents/Resources/app/bin/cursor";

  sketchybarLua = pkgs.lua5_5.withPackages (lp: [ pkgs.sbarlua ]);

  cursorExtensions = [
    "asvetliakov.vscode-neovim"
    "catppuccin.catppuccin-vsc"
    "catppuccin.catppuccin-vsc-icons"
    "catppuccin.catppuccin-vsc-pack"
    "dbaeumer.vscode-eslint"
    "eamodio.gitlens"
    "jnoortheen.nix-ide"
    "mermaidchart.vscode-mermaid-chart"
    "ms-python.python"
    "ms-python.debugpy"
    "redhat.java"
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
  ];

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
    "sketchybar-config" = {
      target = ".config/sketchybar";
      source = pkgs.runCommand "sketchybar-config"
        { nativeBuildInputs = [ pkgs.clang ]; }
        ''
          cp -r ${./file/sketchybar} $out
          chmod -R u+w $out
          substituteInPlace $out/sketchybarrc \
            --replace-fail '#!/usr/bin/env lua' '#!${sketchybarLua}/bin/lua'
          chmod +x $out/sketchybarrc
          chmod +x $out/helpers/media-stream.sh

          # Build event providers
          mkdir -p $out/helpers/event_providers/cpu_load/bin
          clang -std=c99 -O3 \
            $out/helpers/event_providers/cpu_load/cpu_load.c \
            -o $out/helpers/event_providers/cpu_load/bin/cpu_load
          mkdir -p $out/helpers/event_providers/network_load/bin
          clang -std=c99 -O3 \
            $out/helpers/event_providers/network_load/network_load.c \
            -o $out/helpers/event_providers/network_load/bin/network_load
        '';
      recursive = true;
    };
  };

  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      theme = "catppuccin-mocha";
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

  home.activation.restartSketchybar = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if /usr/bin/pgrep -q sketchybar 2>/dev/null; then
      /opt/homebrew/bin/brew services restart sketchybar 2>/dev/null || true
    fi
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

  home.activation.installCursorAgentAcp = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if ! [ -x "$HOME/.npm-global/bin/cursor-agent-acp" ]; then
      echo "Installing cursor-agent-acp..."
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      export NPM_CONFIG_CACHE="$HOME/.npm-global/.cache"
      mkdir -p "$HOME/.npm-global" "$HOME/.npm-global/.cache"
      ${pkgs.nodejs}/bin/npm install -g @blowmage/cursor-agent-acp
    fi
    if [ -x "${cursorCli}" ]; then
      ln -sf "${cursorCli}" "$HOME/.npm-global/bin/cursor-agent"
    fi
  '';
}
