# Agent customisations authored once under home/file/agents/ and rendered
# into each supported agent's native format (Claude Code, Cursor, Gemini CLI,
# Antigravity, Codex).
{ config, pkgs, lib, ... }:
let
  json = pkgs.formats.json { };
  toml = pkgs.formats.toml { };
  agentsDir = ../../file/agents;

  # Reads a Markdown file with flat `key: value` YAML frontmatter.
  readMarkdown = path:
    let
      lines = lib.splitString "\n" (builtins.readFile path);
      close = lib.lists.findFirstIndex (l: l == "---") null (lib.drop 1 lines);
      scalar = v:
        if v == "true" then true
        else if v == "false" then false
        else lib.removeSuffix "\"" (lib.removePrefix "\"" v);
      field = l:
        let m = builtins.match "([A-Za-z_-]+):[ ]*(.*)" l;
        in lib.optional (m != null) (lib.nameValuePair (lib.head m) (scalar (lib.last m)));
    in
    assert lib.assertMsg (lib.head lines == "---" && close != null) "${toString path}: missing frontmatter";
    {
      meta = builtins.listToAttrs (lib.concatMap field (lib.take close (lib.drop 1 lines)));
      body = lib.removePrefix "\n" (lib.concatStringsSep "\n" (lib.drop (close + 2) lines));
    };

  # Every Markdown file in a directory except its README.
  readMarkdownDir = dir:
    lib.optionals (builtins.pathExists dir) (lib.mapAttrsToList
      (file: _: readMarkdown (dir + "/${file}") // { slug = lib.removeSuffix ".md" file; })
      (lib.filterAttrs (file: type: type == "regular" && lib.hasSuffix ".md" file && file != "README.md")
        (builtins.readDir dir)));

  # JSON strings are valid YAML scalars and flow sequences.
  frontmatter = attrs: ''
    ---
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k}: ${builtins.toJSON v}") attrs)}
    ---

  '';

  # --- Subagents: home/file/agents/subagents/<name>.md ---
  # Tiers follow the Model Routing table in home/file/agents/AGENTS.md.
  subagents = readMarkdownDir (agentsDir + "/subagents");
  claudeModel = { volume = "haiku"; standard = "sonnet"; frontier = "opus"; };
  codexEffort = { volume = "low"; standard = "medium"; frontier = "high"; };
  geminiReadOnlyTools = [ "read_file" "read_many_files" "glob" "grep_search" "list_directory" "web_fetch" "google_web_search" ];

  renderSubagent = { meta, body, ... }:
    let
      inherit (meta) name description;
      readonly = meta.readonly or false;
      identity = { inherit name description; };
    in
    {
      # Cursor reads ~/.claude/agents/ too; `readonly` is its field. A copy in
      # ~/.cursor/agents/ would list every subagent twice.
      "ai-agent-claude-${name}" = {
        target = ".claude/agents/${name}.md";
        text = frontmatter (identity // {
          model = claudeModel.${meta.tier};
          inherit readonly;
        } // lib.optionalAttrs readonly {
          disallowedTools = "Write, Edit, MultiEdit, NotebookEdit";
        }) + body;
      };
      "ai-agent-gemini-${name}" = {
        target = ".gemini/agents/${name}.md";
        text = frontmatter (identity // lib.optionalAttrs readonly { tools = geminiReadOnlyTools; }) + body;
      };
      "ai-agent-antigravity-${name}" = {
        target = ".gemini/config/agents/${name}/agent.md";
        text = frontmatter identity + body;
      };
      "ai-agent-codex-${name}" = {
        target = ".codex/agents/${name}.toml";
        source = toml.generate "${name}.toml" (identity // {
          developer_instructions = body;
          model_reasoning_effort = codexEffort.${meta.tier};
          sandbox_mode = if readonly then "read-only" else "workspace-write";
        });
      };
    };
in
{
  # Gemini CLI keeps MCP servers, context files and hooks in one settings.json,
  # so every contributor merges into this option instead of owning the file.
  options.agents.gemini.settings = lib.mkOption {
    type = json.type;
    default = { };
    description = "Contents of ~/.gemini/settings.json.";
  };

  config.home.file = lib.mkMerge ([
    {
      "ai-gemini-settings" = {
        target = ".gemini/settings.json";
        source = json.generate "gemini-settings.json" config.agents.gemini.settings;
      };
    }
  ] ++ map renderSubagent subagents);
}
