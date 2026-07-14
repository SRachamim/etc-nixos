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
  };

  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      theme = "catppuccin-mocha";
      font-family = "FiraCode Nerd Font Mono";
      macos-option-as-alt = true;
      shell-integration = "zsh";
      keybind = [
        "alt+left=unbind"
        "alt+right=unbind"
      ];
    };
  };

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
