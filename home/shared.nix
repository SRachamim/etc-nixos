{ config, pkgs, lib, ... }:
let
  mkMcpServer = name: npxArgs: lib.getExe (pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = [ pkgs.nodejs ];
    excludeShellChecks = [ "SC1090" ];
    text = ''
      source ~/.secrets 2>/dev/null || true
      NPM_CONFIG_CACHE=/tmp/npm-mcp-cache exec npx -y ${npxArgs}
    '';
  });

  mkLocalMcpServer = name: entrypoint: lib.getExe (pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = [ pkgs.nodejs ];
    excludeShellChecks = [ "SC1090" ];
    text = ''
      source ~/.secrets 2>/dev/null || true
      exec node "${entrypoint}"
    '';
  });

  # Per-thread context: resolves the work item, pull request and pinned links
  # for the current worktree and opens them as one browser window, which
  # AeroSpace places in the workspace holding that thread's terminal.
  ctxTool = pkgs.writeShellApplication {
    name = "ctx";
    runtimeInputs = with pkgs; [ azure-cli coreutils git gnugrep gnused ];
    text = builtins.readFile ./file/ctx/ctx.sh;
  };

  mcpServers = {
    "fundguard" = {
      command = mkLocalMcpServer "mcp-fundguard" "$HOME/.local/share/fundguard-mcp/mcp-proxy.js";
      customInstructions = "For Azure DevOps operations (PRs, work items, repos, branches, builds, test plans, wiki, code search), prefer the dedicated Azure DevOps MCP server. Use this server for Datadog, Currents, Sunday, DevTools, and DevOps Tools.";
    };
    "Azure DevOps" = {
      command = lib.getExe (pkgs.writeShellApplication {
        name = "mcp-azure-devops";
        runtimeInputs = [ pkgs.azure-devops-mcp ];
        excludeShellChecks = [ "SC1090" ];
        text = ''
          source ~/.secrets 2>/dev/null || true
          export PERSONAL_ACCESS_TOKEN
          PERSONAL_ACCESS_TOKEN=$(printf ':%s' "$ADO_PAT" | base64)
          exec azure-devops-mcp fundguard -a pat -d core work repositories search test-plans advanced-security
        '';
      });
      customInstructions = "Preferred server for all Azure DevOps operations. Use this over the FundGuard MCP proxy for PRs, work items, repos, branches, builds, test plans, wiki, and code search.";
    };
    "Slack" = {
      command = lib.getExe (pkgs.writeShellApplication {
        name = "mcp-slack";
        runtimeInputs = [ pkgs.slack-mcp-server ];
        excludeShellChecks = [ "SC1090" ];
        text = ''
          source ~/.secrets 2>/dev/null || true
          exec slack-mcp-server -transport stdio
        '';
      });
    };
  };

  skillsDir = ./file/agents/skills;

  # Claude Code only discovers skills ONE level deep: ~/.claude/skills/<name>/SKILL.md
  # Our source uses categories (workflows/, knowledge/, shared/) which Cursor handles
  # via recursive scanning, but Claude Code does not. Flatten for Claude deployment.
  flatClaudeSkills = let
    categories = builtins.attrNames (
      lib.filterAttrs (_: type: type == "directory") (builtins.readDir skillsDir)
    );
  in builtins.listToAttrs (builtins.concatMap (cat:
    let
      catPath = skillsDir + "/${cat}";
      skills = builtins.attrNames (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir catPath)
      );
    in map (skill: {
      name = "ai-claude-skill-${skill}";
      value = {
        source = catPath + "/${skill}";
        target = ".claude/skills/${skill}";
        recursive = true;
      };
    }) skills
  ) categories);

  # Antigravity reads skills from ~/.gemini/antigravity/knowledge/
  antigravityKnowledge = pkgs.runCommand "antigravity-knowledge" {} ''
    mkdir -p $out/artifacts/skills

    for category_dir in ${skillsDir}/workflows ${skillsDir}/knowledge ${skillsDir}/shared; do
      if [ -d "$category_dir" ]; then
        for skill_dir in "$category_dir"/*; do
          if [ -d "$skill_dir" ] && [ -f "$skill_dir/SKILL.md" ]; then
            skill_name=$(basename "$skill_dir")
            cp "$skill_dir/SKILL.md" "$out/artifacts/skills/$skill_name.md"

            mkdir -p "$out/$skill_name"
            cat > "$out/$skill_name/metadata.json" <<MEOF
{
  "summary": "Agent skill: $skill_name",
  "references": ["artifacts/skills/$skill_name.md"]
}
MEOF
          fi
        done
      fi
    done

    mkdir -p "$out/skills_catalog"
    cat > "$out/skills_catalog/metadata.json" <<MEOF
{
  "summary": "Agent Skills Catalog: lists all available skills for workflows like planning, reviewing, and investigating.",
  "references": ["artifacts/skills_catalog.md"]
}
MEOF

    echo "# Agent Skills Catalog" > "$out/artifacts/skills_catalog.md"
    echo "When the user asks for a specific workflow, read the corresponding markdown file below using view_file." >> "$out/artifacts/skills_catalog.md"
    for skill in "$out/artifacts/skills"/*.md; do
      skill_name=$(basename "$skill" .md)
      echo "- **$skill_name**: $skill" >> "$out/artifacts/skills_catalog.md"
    done
  '';
in
{
  home.stateVersion = "23.05";

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    bat.enable = true;
    fzf.enable = true;
    ghostty.enable = true;
    lsd.enable = true;
    starship.enable = true;
    zsh-syntax-highlighting.enable = true;
    # These options tune the catppuccin tmux plugin and must be set *before* it
    # runs; this block is emitted directly above the plugin's run-shell line.
    tmux = {
      enable = true;
      extraConfig = ''
        # Flat window tabs -- mirrors lualine's empty component/section separators.
        set -g @catppuccin_window_status_style "basic"
        set -g @catppuccin_window_number_position "left"
        # #W (window name) is stable under automatic-rename; #T (pane title) is not.
        set -g @catppuccin_window_text " #W"
        set -g @catppuccin_window_current_text " #W"
        # Zoom / bell / activity markers on the tab, so a zoomed pane is obvious.
        set -g @catppuccin_window_flags "icon"
        # Transparent bar, matching neovim's transparent_background.
        set -g @catppuccin_status_background "default"
        set -g @catppuccin_date_time_text " %H:%M"
      '';
    };
  };

  home.sessionVariables = {
    FZF_DEFAULT_COMMAND = "fd -H --type f --strip-cwd-prefix";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
  ];

  home.file = {
    # --- Portable assets: subagents, AGENTS.md to all agent paths ---
    # Skills are deployed ONLY via flatClaudeSkills (~/.claude/skills/) and
    # ~/.gemini/skills/. Cursor discovers skills from ~/.claude/skills/ as a
    # compatibility path. Deploying to ~/.cursor/skills/ or ~/.agents/skills/
    # causes Cursor to show duplicates (it scans all paths but fails to dedup).
    "ai-subagents-agents" = {
      source = ./file/agents/subagents;
      target = ".agents/subagents";
      recursive = true;
    };
    "ai-agents-md" = {
      source = ./file/agents/AGENTS.md;
      target = ".agents/AGENTS.md";
    };
    # Skills are NOT deployed to ~/.cursor/skills/ because Cursor also loads
    # from ~/.claude/skills/ (compatibility) and fails to deduplicate between them.
    # Cursor discovers skills from flatClaudeSkills (~/.claude/skills/) as the single source.
    "ai-subagents-cursor" = {
      source = ./file/agents/subagents;
      target = ".cursor/subagents";
      recursive = true;
      force = true;
    };
    "ai-subagents-claude" = {
      source = ./file/agents/subagents;
      target = ".claude/subagents";
      recursive = true;
    };
    "ai-skills-gemini" = {
      source = ./file/agents/skills;
      target = ".gemini/skills";
      recursive = true;
    };
    "ai-subagents-gemini" = {
      source = ./file/agents/subagents;
      target = ".gemini/subagents";
      recursive = true;
    };
    "ai-agents-md-gemini" = {
      source = ./file/agents/AGENTS.md;
      target = ".gemini/AGENTS.md";
    };
    "cursor-mcp.json" = {
      target = ".cursor/mcp.json";
      force = true;
      text = builtins.toJSON { inherit mcpServers; };
    };
    "ai-gemini-settings" = {
      target = ".gemini/settings.json";
      text = builtins.toJSON {
        context.fileName = [ "GEMINI.md" "AGENTS.md" ];
        inherit mcpServers;
      };
    };
    "ai-antigravity-mcp" = {
      target = ".gemini/config/mcp_config.json";
      force = true;
      text = builtins.toJSON { inherit mcpServers; };
    };
    "ai-antigravity-knowledge" = {
      source = antigravityKnowledge;
      target = ".gemini/antigravity/knowledge";
      recursive = true;
      force = true;
    };
    "ai-agents-md-codex" = {
      source = ./file/agents/AGENTS.md;
      target = ".codex/AGENTS.md";
    };
    "ai-codex-config" = {
      target = ".codex/config.toml";
      source = (pkgs.formats.toml {}).generate "config.toml" {
        mcp_servers = lib.mapAttrs' (name: value:
          lib.nameValuePair (lib.toLower (builtins.replaceStrings [" "] ["-"] name)) value
        ) mcpServers;
      };
    };
    "ai-claude-md" = {
      source = ./file/agents/CLAUDE.md;
      target = ".claude/CLAUDE.md";
    };
    "git-hooks" = {
      source = ./file/git-hooks;
      target = ".config/git/hooks";
      recursive = true;
      force = true;
    };
  } // flatClaudeSkills;

  home.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    azure-cli
    claude-code
    ctxTool
    fd
    lazydocker
    ripgrep
    tmux
    volta
  ];

  # Secrets template -- will be replaced by agenix once host SSH keys are enrolled.
  # See secrets/README.md for migration instructions.
  home.activation.seedClaudeConfig = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.claude"
    if ! [ -f "$HOME/.claude/settings.json" ]; then
      cat > "$HOME/.claude/settings.json" << 'SETTINGS'
{
  "preferences": {
    "terminal_emulator": "ghostty",
    "theme": "dark",
    "verbose": false
  }
}
SETTINGS
    fi

    mcpPayload='${builtins.toJSON { inherit mcpServers; }}'
    if [ -f "$HOME/.claude.json" ]; then
      ${pkgs.jq}/bin/jq -s '.[1] as $patch | .[0] * $patch | .mcpServers = $patch.mcpServers' "$HOME/.claude.json" <(echo "$mcpPayload") > "$HOME/.claude.json.tmp"
      mv "$HOME/.claude.json.tmp" "$HOME/.claude.json"
    else
      echo "$mcpPayload" > "$HOME/.claude.json"
    fi
  '';

  home.activation.manageFundguardProxy = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if [ -d "$HOME/.fundguard" ]; then
      run rm -rf "$HOME/.fundguard"
      verboseEcho "Removed old FundGuard proxy from ~/.fundguard"
    fi

    FGDIR="$HOME/.local/share/fundguard-mcp"
    if [ ! -f "$FGDIR/mcp-proxy.js" ]; then
      run mkdir -p "$FGDIR"
      run ${pkgs.curl}/bin/curl -fsSL "https://mcp.fundguard.io/proxy/bundle.js" \
        -o "$FGDIR/mcp-proxy.js"
      run chmod +x "$FGDIR/mcp-proxy.js"
      echo "https://mcp.fundguard.io" > "$FGDIR/server-url"
      verboseEcho "Installed FundGuard MCP proxy to $FGDIR"
    fi
  '';

  home.activation.createSecretsFile = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if ! [ -f "$HOME/.secrets" ]; then
      cat > "$HOME/.secrets" << 'EOF'
# ~/.secrets - Environment variables for sensitive data
# This file is sourced by your shell. Keep it secure!
# Run: chmod 600 ~/.secrets

# FundGuard MCP Proxy
# FG_USER: your FundGuard email (e.g. first.last@fundguard.com)
# DD_APP_KEY: Datadog app key with logs_read_data scope (https://app.datadoghq.eu/organization-settings/application-keys)
# ADO_PAT: Azure DevOps PAT with Code R/W, Build R, Work Items R/W, Wiki R/W (https://dev.azure.com/FundGuard/_usersSettings/tokens)
# export FG_USER=""
# export DD_APP_KEY=""
# export ADO_PAT=""

# Slack MCP Server (korotovsky/slack-mcp-server)
# Use ONE of: xoxb (bot), xoxp (user), or xoxc+xoxd (browser session)
# export SLACK_MCP_XOXB_TOKEN="xoxb-your-bot-token"
# export SLACK_MCP_XOXP_TOKEN="xoxp-your-user-token"
# export SLACK_MCP_ADD_MESSAGE_TOOL="true"
# export SLACK_MCP_REACTION_TOOL="true"
EOF
      chmod 600 "$HOME/.secrets"
      echo "Created ~/.secrets template. Edit it with your API keys."
    fi
  '';

  home.activation.createImprovementsDir = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.local/share/agent-improvements/pending"
    mkdir -p "$HOME/.local/share/agent-improvements/applied"
    mkdir -p "$HOME/.local/share/agent-improvements/rejected"
  '';

  programs = {
    atuin = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        auto_sync = false;
        update_check = false;
        style = "compact";
        inline_height = 20;
        search_mode = "fuzzy";
        filter_mode = "global";
        filter_mode_shell_up_key_binding = "session";
      };
    };

    bat.enable = true;

    btop.enable = true;

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      historyWidget.command = "";
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
    };

    git = {
      enable = true;
      signing.format = "openpgp";
      settings = {
        alias = {
          br = "branch";
          ci = "commit";
          co = "checkout";
          last = "log -1 HEAD";
          st = "status";
          unstage = "reset HEAD --";
        };
        branch.sort = "-committerdate";
        core = {
          editor = "nvim";
          excludesfile = "~/.gitignore";
          fsmonitor = true;
          hooksPath = "~/.config/git/hooks";
          untrackedCache = true;
        };
        column.ui = "auto";
        commit.verbose = true;
        diff = {
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
          renames = true;
        };
        fetch = {
          all = true;
          prune = true;
          pruneTags = true;
        };
        help.autocorrect = "prompt";
        init.defaultBranch = "master";
        merge.conflictstyle = "zdiff3";
        pull.rebase = true;
        push = {
          autoSetupRemote = true;
          default = "simple";
          followTags = true;
        };
        rebase = {
          autoSquash = true;
          autoStash = true;
          updateRefs = true;
        };
        rerere = {
          autoupdate = true;
          enabled = true;
        };
        tag.sort = "version:refname";
      };
    };

    home-manager.enable = true;

    jq.enable = true;

    lazygit.enable = true;

    lsd.enable = true;

    # Neovim is configured via nixCats in home/programs/neovim/default.nix

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "ssh.dev.azure.com" = {
          HostkeyAlgorithms = "+ssh-rsa";
          PubkeyAcceptedAlgorithms = "+ssh-rsa";
          User = "git";
        };
      };
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    tmux = {
      enable = true;
      # tmux-256color carries italics, truecolor and extended capabilities;
      # screen-256color does not.
      terminal = "tmux-256color";
      shell = "${pkgs.zsh}/bin/zsh";
      historyLimit = 50000;
      baseIndex = 1;
      mouse = true;
      focusEvents = true;
      clock24 = true;

      # Appended after the catppuccin plugin contributed by catppuccin/nix, so
      # the theme is loaded before anything that builds on it. Every binding
      # below is a plugin default and is unbound in stock tmux.
      plugins = lib.mkAfter (with pkgs.tmuxPlugins; [
        # prefix+y, and `y` in copy-mode-vi -> system clipboard.
        # Auto-detects pbcopy/xclip/wl-copy, so it works on both hosts.
        yank

        # prefix+Tab -- fuzzy-grab paths, URLs and quoted strings out of the
        # scrollback. The main reason it is here: lifting file paths straight
        # out of an agent's output.
        {
          plugin = extrakto;
          extraConfig = ''
            set -g @extrakto_grab_area "window recent"
          '';
        }

        # prefix+F -- fuzzy switch session/window/pane.
        tmux-fzf

        # prefix+u -- open a URL from the scrollback.
        fzf-tmux-url

        # prefix+Ctrl+s / prefix+Ctrl+r -- manual layout snapshot and restore.
        # No continuum: session lifecycle belongs to Agent of Empires, and an
        # automatic restore would resurrect sessions AoE no longer tracks.
        {
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-strategy-nvim "session"
            set -g @resurrect-capture-pane-contents "on"
          '';
        }
      ]);

      # Emitted last, after every plugin's run-shell.
      # Stock tmux keybindings (prefix Ctrl+b), plus vim-style pane navigation.
      extraConfig = ''
        setw -g mode-keys vi

        # --- Terminal capabilities: tmux talking to Ghostty ---
        # usstyle: undercurl for LSP diagnostics. sync: no redraw tearing in
        # nvim or streaming agent output. hyperlinks/osc7: clickable OSC 8 links
        # and correct cwd inheritance. clipboard: OSC 52, so copy survives SSH.
        set -as terminal-features ",xterm-ghostty:RGB:usstyle:hyperlinks:sync:clipboard:extkeys:focus:osc7:strikethrough:overline"
        set -as terminal-features ",xterm-256color:RGB:usstyle:clipboard"
        # CSI-u encoding, so nvim and Claude Code can tell Ctrl+Shift+X from Ctrl+X.
        set -s  extended-keys on
        set -g  set-clipboard on
        # Required for yazi's image preview to survive tmux.
        set -g  allow-passthrough on

        # --- Window behaviour ---
        set -g renumber-windows on
        # Land in another session instead of the bare shell when one is killed.
        set -g detach-on-destroy off
        set -g set-titles on
        set -g set-titles-string "#S > #W"
        set -g display-time 2000
        set -g status-interval 5

        # --- Status line ---
        # Top, so it never stacks against lualine at the bottom of an nvim pane.
        # These reference catppuccin modules and must come after the plugin ran.
        set -g status-position top
        set -g status-left-length 100
        set -g status-right-length 100
        set -g status-left  "#{E:@catppuccin_status_session}"
        set -g status-right "#{E:@catppuccin_status_directory}"
        set -ag status-right "#{E:@catppuccin_status_date_time}"

        # Pane navigation: stock tmux only binds the arrow keys.
        # `l` shadows the default last-window binding.
        bind -r h select-pane -L
        bind -r j select-pane -D
        bind -r k select-pane -U
        bind -r l select-pane -R

        # Reload this config into the running server; tmux has no default for it.
        # `r` shadows refresh-client, still reachable via `Ctrl+b : refresh-client`.
        bind r source-file ~/.config/tmux/tmux.conf \; display-message "tmux config reloaded"
      '';
    };

    yazi = {
      enable = true;
      shellWrapperName = "y";
    };

    topgrade = {
      enable = true;
      settings = {
        misc = {
          pre_sudo = true;
          disable = [
            "claude_code"
            "cursor_agent"
            "gem"
            "node"
            "nix"
            "ruby_gems"
          ];
        };
        linux = {
          home_manager_arguments = ["-b" "backup"];
        };
      };
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initContent = lib.mkMerge [
        (lib.mkOrder 1000 ''
          # Source secrets file if it exists
          [ -f "$HOME/.secrets" ] && source "$HOME/.secrets"
        '')
      ];
      shellAliases = {
        switch = "sudo darwin-rebuild switch --flake /Volumes/Development/github.com/srachamim/etc-nixos/main#macbook";
      };
    };
  };
}
