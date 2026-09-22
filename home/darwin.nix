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
}
