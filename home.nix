{ config, pkgs, ... }:
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
              command = "nix-shell";
              args = [
                "-p"
                "nodejs"
                "--run"
                "NPM_CONFIG_CACHE=/tmp/npm-mcp-cache npx -y @azure-devops/mcp@latest fundguard -a azcli"
              ];
            };
          };
        };
      };
      "cursor-rules-functional-typescript-sage" = {
        source = ./home/file/cursor/rules/functional-typescript-sage.mdc;
        target = ".cursor/rules/functional-typescript-sage.mdc";
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
      aider-chat
      azure-cli
      fd
      gemini-cli
      nodejs
      ripgrep
      volta
    ];
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
        plugins = with pkgs.vimPlugins; [
          {
            config = ''
              set termguicolors
              colorscheme catppuccin-mocha
            '';
            plugin = catppuccin-nvim;
          }
          {
            config = builtins.readFile ./home/programs/neovim/coc-nvim.vim;
            plugin = coc-nvim;
          }
          {
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
          coc-tsserver
          {
            config = builtins.readFile ./home/programs/neovim/fzf-vim.vim;
            plugin = fzf-vim;
          }
          {
            config = builtins.readFile ./home/programs/neovim/vim-airline.vim;
            plugin = vim-airline;
          }
          vim-commentary
          vim-devicons
          {
            config = builtins.readFile ./home/programs/neovim/vim-html-template-literals.vim;
            plugin = vim-html-template-literals;
          }
          vim-fugitive
          vim-gitgutter
          vim-highlightedyank
          git-messenger-vim
          {
            config = builtins.readFile ./home/programs/neovim/vim-polyglot.vim;
            plugin = vim-polyglot;
          }
          orgmode
          vim-repeat
          vim-surround
          vim-unimpaired
        ];
        vimAlias = true;
        vimdiffAlias = true;
      };
      ssh = {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks = {
          "ssh.dev.azure.com" = {
            extraOptions = {
              "HostkeyAlgorithms"  = "+ssh-rsa";
              "PubkeyAcceptedAlgorithms" = "+ssh-rsa";
              "User" = "git";
            };
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
