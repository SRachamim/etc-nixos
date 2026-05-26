{ config, pkgs, lib, ... }:
let
  nix-shell = "/nix/var/nix/profiles/default/bin/nix-shell";
  agentic-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "agentic-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "carlos-algms";
      repo = "agentic.nvim";
      rev = "main";
      sha256 = "sha256-eRQjzn60q6oiw6gyXEt9t44TeJQLm0yNX75sjt3jQgs=";
    };
    doCheck = false;
  };
in
{
    imports = [
      <catppuccin/modules/home-manager>
    ];

    catppuccin = {
      enable = true;
      flavor = "mocha";
      bat.enable = true;
      fzf.enable = true;
      lsd.enable = true;
      starship.enable = true;
      zellij.enable = true;
      zsh-syntax-highlighting.enable = true;
    };
    home.username = "sahar.rachamim";
    home.homeDirectory = "/Users/sahar.rachamim";
    home.stateVersion = "23.05";
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "vim-airline"
      "vim-closetag"
      "vim-commentary"
      "vim-css-color"
      "vim-devicons"
      "vim-fugitive"
      "vim-gitgutter"
      "vim-hardtime"
      "vim-highlightedyank"
      "vim-html-template-literals"
      "vim-orgmode"
      "vim-polyglot"
      "vim-repeat"
      "vim-surround"
      "vim-unimpaired"
      "catppuccin-nvim"
      "coc-nvim"
      "fzf-vim"
      "git-messenger-vim"
      "orgmode"
    ];
    home.file = {
      "zellij-layout-fg" = {
        target = ".config/zellij/layouts/fg.kdl";
        source = ./home/file/zellij/layouts/fg.kdl;
      };
      "cursor-mcp.json" = {
        target = ".cursor/mcp.json";
        force = true;
        text = builtins.toJSON {
          mcpServers = {
            "Azure DevOps" = {
              command = nix-shell;
              args = [
                "-p"
                "nodejs"
                "--run"
                "source ~/.secrets 2>/dev/null; NPM_CONFIG_CACHE=/tmp/npm-mcp-cache npx -y @azure-devops/mcp@latest fundguard -a pat"
              ];
            };
            "Currents" = {
              command = nix-shell;
              args = [
                "-p"
                "nodejs"
                "--run"
                "source ~/.secrets 2>/dev/null; NPM_CONFIG_CACHE=/tmp/npm-mcp-cache npx -y @currents/mcp@latest"
              ];
            };
            "Slack" = {
              command = nix-shell;
              args = [
                "-p"
                "nodejs"
                "--run"
                "source ~/.secrets 2>/dev/null; NPM_CONFIG_CACHE=/tmp/npm-mcp-cache npx -y @zencoderai/slack-mcp-server@latest"
              ];
            };
            "Datadog" = {
              command = nix-shell;
              args = [
                "-p"
                "nodejs"
                "--run"
                "source ~/.secrets 2>/dev/null; NPM_CONFIG_CACHE=/tmp/npm-mcp-cache npx -y @winor30/mcp-server-datadog@latest"
              ];
            };
          };
        };
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
      "ai-config-cursor" = {
        source = ./home/file/ai;
        target = ".cursor";
        recursive = true;
      };
      "ai-config-claude" = {
        source = ./home/file/ai;
        target = ".claude";
        recursive = true;
      };
      "git-hooks" = {
        source = ./home/file/git-hooks;
        target = ".config/git/hooks";
        recursive = true;
      };
      "ghostty-config" = {
        target = ".config/ghostty/config";
        source = ./home/file/ghostty/config;
      };
      "aerospace-config" = {
        source = ./home/file/aerospace/aerospace.toml;
        target = ".aerospace.toml";
      };
    };
    home.packages = with pkgs; [
      nerd-fonts.fira-code
      # aider-chat
      azure-cli
      fd
      gemini-cli
      nodejs
      ripgrep
      volta
    ];
    home.sessionPath = [ "$HOME/.local/bin" ];
    home.activation.createSecretsFile = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      if ! [ -f "$HOME/.secrets" ]; then
        cat > "$HOME/.secrets" << 'EOF'
# ~/.secrets - Environment variables for sensitive data
# This file is sourced by your shell. Keep it secure!
# Run: chmod 600 ~/.secrets

# Cursor Agent API Key (get from cursor.com settings)
# export CURSOR_API_KEY=""

# OpenAI API Key
# export OPENAI_API_KEY=""

# Anthropic API Key
# export ANTHROPIC_API_KEY=""

# Currents.dev API Key (get from currents.dev dashboard)
# export CURRENTS_API_KEY=""

# Slack MCP Server (get from api.slack.com/apps)
# Use User Token (xoxp-...) to post as yourself, Bot Token (xoxb-...) to post as app
# export SLACK_BOT_TOKEN="xoxp-your-user-token"
# export SLACK_TEAM_ID="T0123456789"
# export SLACK_CHANNEL_IDS="C123,C456"  # Optional: comma-separated channel IDs

# Datadog MCP Server (get from app.datadoghq.com/organization-settings/api-keys)
# export DATADOG_API_KEY=""
# export DATADOG_APP_KEY=""
# export DATADOG_SITE="datadoghq.com"  # Optional: datadoghq.eu for EU

# Add other secrets below...
EOF
        chmod 600 "$HOME/.secrets"
        echo "Created ~/.secrets template. Edit it with your API keys."
      fi
    '';
    home.activation.fixCocPermissions = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      # Fix coc.nvim directory permissions if they were created by root (Nix builds)
      if [ -d "$HOME/.config/coc" ]; then
        find "$HOME/.config/coc" -user root -exec chown $(id -u):$(id -g) {} \; 2>/dev/null || true
      fi
    '';
    home.activation.initCursorSettings = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      # Initialize Cursor settings if not present (don't overwrite user changes)
      CURSOR_SETTINGS="$HOME/Library/Application Support/Cursor/User/settings.json"
      mkdir -p "$(dirname "$CURSOR_SETTINGS")"
      # Remove symlink if it exists (from previous home-manager config)
      if [ -L "$CURSOR_SETTINGS" ]; then
        rm "$CURSOR_SETTINGS"
      fi
      # Copy initial settings only if file doesn't exist
      if [ ! -f "$CURSOR_SETTINGS" ]; then
        cat > "$CURSOR_SETTINGS" << 'EOF'
${builtins.readFile ./home/file/ai/settings.json}
EOF
      fi
    '';
    home.activation.installGeminiKnowledge = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      echo "Deploying Gemini Knowledge Items..."
      KNOWLEDGE_DIR="$HOME/.gemini/antigravity/knowledge"
      mkdir -p "$KNOWLEDGE_DIR/artifacts/commands"
      mkdir -p "$KNOWLEDGE_DIR/artifacts/skills"

      # Sync skills and generate metadata
      for skill_dir in ${./home/file/ai/skills}/*; do
        if [ -d "$skill_dir" ]; then
          skill_name=$(basename "$skill_dir")
          rm -f "$KNOWLEDGE_DIR/artifacts/skills/$skill_name.md"
          cat "$skill_dir/SKILL.md" > "$KNOWLEDGE_DIR/artifacts/skills/$skill_name.md"
          
          mkdir -p "$KNOWLEDGE_DIR/$skill_name"
          cat > "$KNOWLEDGE_DIR/$skill_name/metadata.json" << MEOF
{
  "summary": "Agent skill: $skill_name",
  "references": ["$KNOWLEDGE_DIR/artifacts/skills/$skill_name.md"]
}
MEOF
        fi
      done

      # Copy commands
      for cmd_file in ${./home/file/ai/commands}/*.md; do
        cmd_name=$(basename "$cmd_file")
        rm -f "$KNOWLEDGE_DIR/artifacts/commands/$cmd_name"
        cat "$cmd_file" > "$KNOWLEDGE_DIR/artifacts/commands/$cmd_name"
      done

      # Generate Commands Catalog KI
      mkdir -p "$KNOWLEDGE_DIR/commands_catalog"
      cat > "$KNOWLEDGE_DIR/commands_catalog/metadata.json" << MEOF
{
  "summary": "Agent Commands Catalog: lists all available commands for workflows like planning, reviewing, and investigating.",
  "references": ["$KNOWLEDGE_DIR/artifacts/commands_catalog.md"]
}
MEOF

      # Generate the actual catalog markdown
      echo "# Agent Commands Catalog" > "$KNOWLEDGE_DIR/artifacts/commands_catalog.md"
      echo "When the user asks for a specific workflow, read the corresponding markdown file below using view_file." >> "$KNOWLEDGE_DIR/artifacts/commands_catalog.md"
      for cmd in "$KNOWLEDGE_DIR/artifacts/commands"/*.md; do
        cmd_name=$(basename "$cmd" .md)
        echo "- **$cmd_name**: $cmd" >> "$KNOWLEDGE_DIR/artifacts/commands_catalog.md"
      done
    '';
    home.activation.installCursorCli = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      if ! [ -x "$HOME/.local/bin/cursor-agent" ]; then
        echo "Installing Cursor CLI..."
        export PATH="${pkgs.curl}/bin:${pkgs.gnutar}/bin:${pkgs.gzip}/bin:${pkgs.coreutils}/bin:$PATH"
        ${pkgs.curl}/bin/curl https://cursor.com/install -fsS | ${pkgs.bash}/bin/bash
      fi
    '';
    home.activation.installCursorAgentAcp = config.lib.dag.entryAfter [ "writeBoundary" "installCursorCli" ] ''
      # Install cursor-agent-acp if not present
      if ! [ -x "$HOME/.npm-global/bin/cursor-agent-acp" ]; then
        echo "Installing cursor-agent-acp..."
        export NPM_CONFIG_PREFIX="$HOME/.npm-global"
        export NPM_CONFIG_CACHE="$HOME/.npm-global/.cache"
        mkdir -p "$HOME/.npm-global" "$HOME/.npm-global/.cache"
        ${pkgs.nodejs}/bin/npm install -g @blowmage/cursor-agent-acp
      fi
      # Create symlink so cursor-agent-acp can find cursor-agent
      if [ -x "$HOME/.local/bin/cursor-agent" ]; then
        ln -sf "$HOME/.local/bin/cursor-agent" "$HOME/.npm-global/bin/cursor-agent"
      fi
    '';
    programs = {
      bat = {
        enable = true;
      };
      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv = {
          enable = true;
        };
      };
      fzf = {
        enable = true;
      };
      zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
      git = {
        enable = true;
        signing = {
          format = "openpgp";
        };
        settings = {
          alias = {
            br = "branch";
            ci = "commit";
            co = "checkout";
            last = "log -1 HEAD";
            st = "status";
            unstage = "reset HEAD --";
          };
          branch = {
            sort = "-committerdate";
          };
          core = {
            editor = "nvim";
            excludesfile = "~/.gitignore";
            fsmonitor = true;
            hooksPath = "~/.config/git/hooks";
            untrackedCache = true;
          };
          column = {
            ui = "auto";
          };
          commit = {
            verbose = true;
          };
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
          help = {
            autocorrect = "prompt";
          };
          init = {
            defaultBranch = "master";
          };
          merge = {
            conflictstyle = "zdiff3";
          };
          pull = {
            rebase = true;
          };
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
          tag = {
            sort = "version:refname";
          };
        };
      };
      home-manager = {
        enable = true;
      };
      jq = {
        enable = true;
      };
      lsd = {
        enable = true;
      };
      neovim = {
        coc = {
          enable = true;
          settings = {
            "eslint.autoFixOnSave" = true;
            "tsserver.enableJavascript" = false;
          };
        };
        enable = true;
        extraConfig = builtins.readFile ./home/programs/neovim/rc.vim;
        withRuby = false;
        withPython3 = false;
        plugins = with pkgs.vimPlugins; [
          {
            type = "viml";
            config = ''
              set termguicolors
              colorscheme catppuccin-mocha
            '';
            plugin = catppuccin-nvim;
          }
          {
            type = "viml";
            config = builtins.readFile ./home/programs/neovim/coc-nvim.vim;
            plugin = coc-nvim;
          }
          {
            type = "viml";
            config = builtins.readFile ./home/programs/neovim/vim-closetag.vim;
            plugin = vim-closetag;
          }
          coc-css
          vim-css-color
          vim-hardtime
          vim-orgmode
          coc-html
          coc-java
          coc-json
          coc-markdownlint
          coc-sh
          coc-tailwindcss

          {
            type = "viml";
            config = builtins.readFile ./home/programs/neovim/fzf-vim.vim;
            plugin = fzf-vim;
          }
          {
            type = "viml";
            config = builtins.readFile ./home/programs/neovim/vim-airline.vim;
            plugin = vim-airline;
          }
          vim-commentary
          vim-devicons
          {
            type = "viml";
            config = builtins.readFile ./home/programs/neovim/vim-html-template-literals.vim;
            plugin = vim-html-template-literals;
          }
          vim-fugitive
          vim-gitgutter
          vim-highlightedyank
          git-messenger-vim
          {
            type = "viml";
            config = builtins.readFile ./home/programs/neovim/vim-polyglot.vim;
            plugin = vim-polyglot;
          }
          orgmode
          vim-repeat
          vim-surround
          vim-unimpaired
          {
            type = "lua";
            config = ''
              require("agentic").setup({
                provider = "cursor-acp",
                debug = false,
                acp_providers = {
                  ["cursor-acp"] = {
                    name = "Cursor Agent ACP",
                    command = vim.fn.expand("~/.npm-global/bin/cursor-agent-acp"),
                    args = { "-c", vim.fn.expand("~/.config/cursor-agent-acp/config.json") },
                    env = {
                      NODE_NO_WARNINGS = "1",
                      IS_AI_TERMINAL = "1",
                      PATH = vim.fn.expand("~/.npm-global/bin") .. ":" .. vim.fn.expand("~/.local/bin") .. ":" .. vim.env.PATH,
                      HOME = vim.fn.expand("~"),
                    },
                  },
                },
              })
            '';
            plugin = agentic-nvim;
          }
        ];
        vimAlias = true;
        vimdiffAlias = true;
      };
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
      };
      topgrade = {
        enable = true;
        settings = {
          misc = {
            pre_sudo = true;
            disable = [
              "gem"
              "ruby_gems"
            ];
          };
        };
      };
      zsh = {
        enable = true;
        autosuggestion = {
          enable = true;
        };
        syntaxHighlighting = {
          enable = true;
        };
        initContent = builtins.readFile ./home/programs/.zshrc;
        shellAliases = {
          zj = "zellij";
          fg = "zellij --layout fg";
        };
      };
    };
}
