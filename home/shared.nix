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
    tmux.enable = true;
    zsh-syntax-highlighting.enable = true;
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
    "ai-gemini-settings" = {
      target = ".gemini/settings.json";
      text = builtins.toJSON {
        context.fileName = [ "GEMINI.md" "AGENTS.md" ];
        inherit mcpServers;
      };
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
      ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$HOME/.claude.json" <(echo "$mcpPayload") > "$HOME/.claude.json.tmp"
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
      terminal = "screen-256color";
      shell = "${pkgs.zsh}/bin/zsh";
      # Stock tmux keybindings (prefix Ctrl+b). Cosmetic + copy-mode only.
      extraConfig = ''
        setw -g mode-keys vi
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
