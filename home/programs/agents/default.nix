# Agent customisations authored once under home/file/agents/ and rendered
# into each supported agent's native format (Claude Code, Cursor, Gemini CLI,
# Antigravity, Codex).
{ config, pkgs, lib, ... }:
let
  json = pkgs.formats.json { };
in
{
  # Gemini CLI keeps MCP servers, context files and hooks in one settings.json,
  # so every contributor merges into this option instead of owning the file.
  options.agents.gemini.settings = lib.mkOption {
    type = json.type;
    default = { };
    description = "Contents of ~/.gemini/settings.json.";
  };

  config.home.file."ai-gemini-settings" = {
    target = ".gemini/settings.json";
    source = json.generate "gemini-settings.json" config.agents.gemini.settings;
  };
}
