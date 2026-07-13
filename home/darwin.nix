{ config, pkgs, lib, ... }:
{
  home.username = "sahar.rachamim";
  home.homeDirectory = "/Users/sahar.rachamim";

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
      font-family = "FiraCode Nerd Font Mono";
      macos-option-as-alt = true;
      shell-integration = "zsh";
      keybind = [
        "ctrl+h=goto_split:left"
        "ctrl+j=goto_split:bottom"
        "ctrl+k=goto_split:top"
        "ctrl+l=goto_split:right"
        "cmd+d=new_split:right"
        "cmd+shift+d=new_split:down"
      ];
    };
  };

  home.activation.installCursorCli = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if ! [ -x "$HOME/.local/bin/cursor-agent" ]; then
      echo "Installing Cursor CLI..."
      export PATH="${pkgs.curl}/bin:${pkgs.gnutar}/bin:${pkgs.gzip}/bin:${pkgs.coreutils}/bin:$PATH"
      ${pkgs.curl}/bin/curl https://cursor.com/install -fsS | ${pkgs.bash}/bin/bash
    fi
  '';

  home.activation.installCursorAgentAcp = config.lib.dag.entryAfter [ "writeBoundary" "installCursorCli" ] ''
    if ! [ -x "$HOME/.npm-global/bin/cursor-agent-acp" ]; then
      echo "Installing cursor-agent-acp..."
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      export NPM_CONFIG_CACHE="$HOME/.npm-global/.cache"
      mkdir -p "$HOME/.npm-global" "$HOME/.npm-global/.cache"
      ${pkgs.nodejs}/bin/npm install -g @blowmage/cursor-agent-acp
    fi
    if [ -x "$HOME/.local/bin/cursor-agent" ]; then
      ln -sf "$HOME/.local/bin/cursor-agent" "$HOME/.npm-global/bin/cursor-agent"
    fi
  '';
}
