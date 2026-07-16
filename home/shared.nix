{ config, pkgs, lib, ... }:
let
  zellij-autolock-wasm = pkgs.fetchurl {
    url = "https://github.com/fresh2dev/zellij-autolock/releases/download/0.2.2/zellij-autolock.wasm";
    hash = "sha256-aclWB7/ZfgddZ2KkT9vHA6gqPEkJ27vkOVLwIEh7jqQ=";
  };

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

  mcpServers = {
    "fundguard" = {
      command = mkLocalMcpServer "mcp-fundguard" "$HOME/.local/share/fundguard-mcp/mcp-proxy.js";
    };
    "Slack" = {
      command = mkMcpServer "mcp-slack" "@zencoderai/slack-mcp-server@latest";
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

  # Build the Antigravity knowledge directory at Nix evaluation time
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
    ghostty.enable = false;
    lsd.enable = true;
    starship.enable = true;
    zellij.enable = true;
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
    "zellij-autolock" = {
      target = ".config/zellij/plugins/zellij-autolock.wasm";
      source = zellij-autolock-wasm;
    };
    "zellij-layout-fg" = {
      target = ".config/zellij/layouts/fg.kdl";
      source = ./file/zellij/layouts/fg.kdl;
    };
    "zellij-layout-ai" = {
      target = ".config/zellij/layouts/ai.kdl";
      source = ./file/zellij/layouts/ai.kdl;
    };
    "cursor-mcp.json" = {
      target = ".cursor/mcp.json";
      force = true;
      text = builtins.toJSON { inherit mcpServers; };
    };
    "cursor-agent-acp-config" = {
      target = ".config/cursor-agent-acp/config.json";
      text = builtins.toJSON {
        cursorAgent = {
          model = "opus-4-thinking";
          args = [ "--model" "opus-4-thinking" ];
        };
      };
    };
    # --- Portable assets: skills, subagents, AGENTS.md to all agent paths ---
    "ai-skills-agents" = {
      source = ./file/agents/skills;
      target = ".agents/skills";
      recursive = true;
    };
    "ai-subagents-agents" = {
      source = ./file/agents/subagents;
      target = ".agents/subagents";
      recursive = true;
    };
    "ai-agents-md" = {
      source = ./file/agents/AGENTS.md;
      target = ".agents/AGENTS.md";
    };
    "ai-skills-cursor" = {
      source = ./file/agents/skills;
      target = ".cursor/skills";
      recursive = true;
      force = true;
    };
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
    "ai-cursor-hooks" = {
      source = ./file/agents/hooks.json;
      target = ".cursor/hooks.json";
      force = true;
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
    fd
    gemini-cli
    lazydocker
    ripgrep
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

# Slack MCP Server (get from api.slack.com/apps)
# export SLACK_BOT_TOKEN="xoxp-your-user-token"
# export SLACK_TEAM_ID="T0123456789"
EOF
      chmod 600 "$HOME/.secrets"
      echo "Created ~/.secrets template. Edit it with your API keys."
    fi
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

    zellij = {
      enable = true;
      settings = {
        theme = "catppuccin-mocha";
      };
      extraConfig = ''
        plugins {
            autolock location="file:~/.config/zellij/plugins/zellij-autolock.wasm" {
                is_enabled false
                triggers "nvim|vim|git|fzf|zoxide|atuin|lazygit|lazydocker|claude"
                reaction_seconds "0.3"
                print_to_log false
            }
        }

        load_plugins {
            autolock
        }

        keybinds {
            shared_except "locked" {
                unbind "Alt f" "Alt n"
                unbind "Alt h" "Alt l" "Alt j" "Alt k"
                unbind "Alt Left" "Alt Right" "Alt Down" "Alt Up"
                unbind "Alt i" "Alt o"
                unbind "Alt =" "Alt +" "Alt -"
                unbind "Alt [" "Alt ]"
                unbind "Alt p" "Alt Shift p"
                bind "Ctrl g" {
                    MessagePlugin "autolock" { payload "enable"; };
                    SwitchToMode "Locked";
                }
            }
            locked {
                bind "Ctrl g" {
                    MessagePlugin "autolock" { payload "disable"; };
                    SwitchToMode "Normal";
                }
            }
            shared_except "move" "locked" {
                bind "Ctrl h" { MoveFocusOrTab "Left"; }
                bind "Ctrl l" { MoveFocusOrTab "Right"; }
                bind "Ctrl j" { MoveFocus "Down"; }
                bind "Ctrl k" { MoveFocus "Up"; }
            }
        }
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
          co () {
            tmuxinator s fg $1
          }

          co-b () {
            git worktree -b $1 ../$1
            co $1
          }

          co-add () {
            git worktree add ../$1 $1
            co $1
          }

          co-d () {
            git worktree remove $1
          }

          # Source secrets file if it exists
          [ -f "$HOME/.secrets" ] && source "$HOME/.secrets"
        '')
      ];
      shellAliases = {
        zj = "zellij";
        fg = "zellij --layout fg";
        ai = "zellij --layout ai";
        switch = "sudo darwin-rebuild switch --flake /Volumes/Development/github.com/srachamim/etc-nixos/main#macbook";
      };
    };
  };
}
