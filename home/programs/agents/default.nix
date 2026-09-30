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
  # Read-only means no file writes, matching Claude's disallowedTools; MCP
  # tools stay available so subagents like `researcher` can fetch.
  geminiReadOnlyTools = [ "read_file" "read_many_files" "glob" "grep_search" "list_directory" "web_fetch" "google_web_search" "mcp_*" ];

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

  # --- Hooks: home/file/agents/hooks/<name>/{hook.json,run.sh} ---
  # Generic events and tool classes, mapped to each agent's own names. Only
  # exact equivalents are mapped; an agent missing the event or tool class
  # gets the hook's `fallback` instruction instead.
  hookEvents = {
    claude = { sessionStart = "SessionStart"; promptSubmit = "UserPromptSubmit"; preToolUse = "PreToolUse"; postToolUse = "PostToolUse"; stop = "Stop"; notification = "Notification"; };
    cursor = { sessionStart = "sessionStart"; promptSubmit = "beforeSubmitPrompt"; preToolUse = "preToolUse"; postToolUse = "postToolUse"; stop = "stop"; };
    gemini = { sessionStart = "SessionStart"; promptSubmit = "BeforeAgent"; preToolUse = "BeforeTool"; postToolUse = "AfterTool"; stop = "AfterAgent"; notification = "Notification"; };
    antigravity = { preToolUse = "PreToolUse"; postToolUse = "PostToolUse"; stop = "Stop"; };
    codex = { sessionStart = "SessionStart"; promptSubmit = "UserPromptSubmit"; preToolUse = "PreToolUse"; postToolUse = "PostToolUse"; stop = "Stop"; };
  };
  toolEvents = [ "preToolUse" "postToolUse" ];
  toolMatchers = {
    claude = { shell = "Bash"; edit = "Edit|Write|MultiEdit|NotebookEdit"; read = "Read|Grep|Glob"; mcp = "mcp__.*"; };
    cursor = { shell = "Shell"; edit = "Write|Delete"; read = "Read|Grep"; mcp = "MCP:.*"; };
    gemini = { shell = "run_shell_command"; edit = "write_file|replace"; read = "read_file|read_many_files|glob|grep_search|list_directory"; mcp = "mcp_.*"; };
    antigravity = { shell = "run_command"; edit = "write_to_file|replace_file_content|multi_replace_file_content"; read = "view_file|list_dir|grep_search|find_by_name"; mcp = "mcp_.*"; };
    # Codex reads files through its shell tool, so `read` has no equivalent.
    codex = { shell = "Bash"; edit = "apply_patch|Edit|Write"; mcp = "mcp__.*"; };
  };
  # What an agent expects on stdout when a hook allows the action silently.
  allowOutput = agent: event:
    if event == "preToolUse" && agent == "cursor" then ''{"permission":"allow"}''
    else if event == "preToolUse" && agent == "antigravity" then ''{"decision":"allow"}''
    else "{}";

  hooksDir = agentsDir + "/hooks";
  hooks = lib.optionals (builtins.pathExists hooksDir) (lib.mapAttrsToList
    (name: _:
      let
        dir = hooksDir + "/${name}";
        spec = { matcher = "any"; packages = [ ]; } // lib.importJSON (dir + "/hook.json");
      in
      assert lib.assertMsg (hookEvents.claude ? ${spec.event}) "hook ${name}: unknown event ${spec.event}";
      assert lib.assertMsg (spec.matcher == "any" || toolMatchers.claude ? ${spec.matcher}) "hook ${name}: unknown matcher ${spec.matcher}";
      spec // {
        inherit name;
        script = lib.getExe (pkgs.writeShellApplication {
          name = "agent-hook-${name}";
          runtimeInputs = map (p: pkgs.${p}) spec.packages;
          text = builtins.readFile (dir + "/run.sh");
        });
      })
    (lib.filterAttrs (_: type: type == "directory") (builtins.readDir hooksDir)));

  # A hook in one agent's terms, or null when the agent has no equivalent.
  nativeHook = agent: hook:
    let
      isTool = builtins.elem hook.event toolEvents;
      event = hookEvents.${agent}.${hook.event} or null;
      matcher = if hook.matcher == "any" then "*" else toolMatchers.${agent}.${hook.matcher} or null;
    in
    if event == null || (isTool && matcher == null) then null
    else {
      inherit (hook) name;
      inherit event;
      matcher = if isTool then matcher else null;
      # run.sh exits 0 to allow (printing nothing) and 2 to block (reason on
      # stderr); the wrapper supplies the agent's own "allow" payload.
      command = toString (pkgs.writeShellScript "agent-hook-${hook.name}-${agent}" ''
        allow=${lib.escapeShellArg (allowOutput agent hook.event)}
        out=$(AGENT_HOOK_AGENT=${agent} ${hook.script}) || exit $?
        printf '%s' "''${out:-$allow}"
      '');
    };

  nativeHooks = agent: lib.filter (h: h != null) (map (nativeHook agent) hooks);
  unsupportedHooks = agent: lib.filter (h: nativeHook agent h == null) hooks;

  # { <event> = [ entry ... ]; } for one agent.
  hooksByEvent = agent: entry: lib.foldl'
    (acc: h: acc // { ${h.event} = (acc.${h.event} or [ ]) ++ [ (entry h) ]; })
    { }
    (nativeHooks agent);
  withMatcher = h: attrs: lib.optionalAttrs (h.matcher != null) { inherit (h) matcher; } // attrs;
  commandHook = h: { type = "command"; inherit (h) command; };
  # Claude, Gemini and Codex share this nesting.
  nestedEntry = h: withMatcher h { hooks = [ (commandHook h) ]; };

  claudeHooks = hooksByEvent "claude" nestedEntry;
  geminiHooks = hooksByEvent "gemini" (h: withMatcher h { hooks = [ (commandHook h // { inherit (h) name; }) ]; });
  codexHooks = hooksByEvent "codex" nestedEntry;
  cursorHooks = hooksByEvent "cursor" (h: withMatcher h { inherit (h) command; });
  # Antigravity groups events under a per-hook name; only tool events nest.
  antigravityHooks = lib.foldl' lib.recursiveUpdate { } (map
    (h: { ${h.name}.${h.event} = [ (if h.matcher != null then { inherit (h) matcher; hooks = [ (commandHook h) ]; } else commandHook h) ]; })
    (nativeHooks "antigravity"));

  # --- Output styles: home/file/agents/output-styles/<name>.md ---
  # Only Claude Code has output styles. The closest type elsewhere is a
  # user-invoked skill that switches the style on for the rest of the session.
  outputStyles = readMarkdownDir (agentsDir + "/output-styles");
  renderOutputStyle = style:
    let
      skill = "${style.slug}-output-style";
      text = frontmatter {
        name = skill;
        description = "Switches responses to the ${style.meta.name} output style for the rest of the session. ${style.meta.description}";
        disable-model-invocation = true;
      } + ''
        # ${style.meta.name} Output Style

        Apply the style below to every remaining response in this session, until the user asks to switch back.

      '' + style.body;
    in
    {
      "ai-output-style-claude-${style.slug}" = {
        target = ".claude/output-styles/${style.slug}.md";
        source = agentsDir + "/output-styles/${style.slug}.md";
      };
      "ai-output-style-gemini-${style.slug}" = { target = ".gemini/skills/output-styles/${skill}/SKILL.md"; inherit text; };
      # Unique name, so Cursor's ~/.claude/skills duplicate problem cannot arise.
      "ai-output-style-cursor-${style.slug}" = { target = ".cursor/skills/${skill}/SKILL.md"; inherit text; };
      "ai-output-style-antigravity-${style.slug}" = { target = ".gemini/antigravity/knowledge/artifacts/skills/${skill}.md"; inherit text; };
      "ai-output-style-antigravity-meta-${style.slug}" = {
        target = ".gemini/antigravity/knowledge/${skill}/metadata.json";
        text = builtins.toJSON { summary = "Agent skill: ${skill}"; references = [ "artifacts/skills/${skill}.md" ]; };
      };
    };

  # --- Fallbacks: the closest supported type for agents lacking one ---
  # A hook an agent cannot run becomes an always-on instruction in a file only
  # that agent reads, so agents that run the real hook never see it.
  fallbacks = agent: map (h: "- **${h.name}** (${h.event}): ${h.fallback}") (unsupportedHooks agent);
  fallbackDoc = agent: ''
    # Agent fallbacks

    Behaviours other agents enforce with a hook or feature this agent lacks.
    Follow them as standing instructions. Generated from home/file/agents/.

    ${lib.concatStringsSep "\n" (fallbacks agent)}
  '';
  fallbackFile = agent: target:
    lib.optionalAttrs (fallbacks agent != [ ]) {
      "ai-fallbacks-${agent}" = { inherit target; text = fallbackDoc agent; };
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

  config = {
    programs.claude-code.settings.hooks = claudeHooks;

    agents.gemini.settings = lib.mkMerge [
      (lib.mkIf (geminiHooks != { }) { hooks = geminiHooks; })
      # A context file only Gemini CLI loads; Antigravity reads GEMINI.md and
      # AGENTS.md from the same directory.
      (lib.mkIf (fallbacks "gemini" != [ ]) { context.fileName = [ "GEMINI-CLI.md" ]; })
    ];

    # Cursor has no file-based global instructions to carry a fallback, and
    # Codex has no skills deployment to carry an output style.
    warnings = map (f: "agents: Cursor cannot receive fallback ${f}") (fallbacks "cursor")
      ++ map (s: "agents: Codex cannot receive output style ${s.slug} (no skills deployment)") outputStyles;

    home.file = lib.mkMerge ([
      {
        "ai-gemini-settings" = {
          target = ".gemini/settings.json";
          source = json.generate "gemini-settings.json" config.agents.gemini.settings;
        };
        # Codex reads one global instructions file, so its fallbacks are appended.
        "ai-agents-md-codex" = {
          target = ".codex/AGENTS.md";
          text = builtins.readFile (agentsDir + "/AGENTS.md")
            + lib.optionalString (fallbacks "codex" != [ ]) ("\n" + fallbackDoc "codex");
        };
      }
      (lib.optionalAttrs (cursorHooks != { }) {
        "ai-hooks-cursor" = { target = ".cursor/hooks.json"; source = json.generate "hooks.json" { version = 1; hooks = cursorHooks; }; };
      })
      (lib.optionalAttrs (codexHooks != { }) {
        "ai-hooks-codex" = { target = ".codex/hooks.json"; source = json.generate "hooks.json" { hooks = codexHooks; }; };
      })
      (lib.optionalAttrs (antigravityHooks != { }) {
        "ai-hooks-antigravity" = { target = ".gemini/config/hooks.json"; source = json.generate "hooks.json" antigravityHooks; };
      })
      (fallbackFile "claude" ".claude/rules/agent-fallbacks.md")
      (fallbackFile "gemini" ".gemini/GEMINI-CLI.md")
      (fallbackFile "antigravity" ".gemini/config/rules/agent-fallbacks.md")
    ] ++ map renderSubagent subagents ++ map renderOutputStyle outputStyles);
  };
}
