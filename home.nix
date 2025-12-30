{ config, pkgs, ... }:
{
    home.username = "sahar.rachamim";
    home.homeDirectory = "/Users/sahar.rachamim";
    home.stateVersion = "23.05";
    home.file = {
      "tmuxinator-fg.yaml" = {
        source = ./home/file/tmuxinator/fg.yaml;
        target = ".config/tmuxinator/fg.yaml";
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
    };
    home.packages = with pkgs; [
      # nerdfonts
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
        config = {
          theme = "Nord";
        };
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
      git = {
        aliases = {
          br = "branch";
          ci = "commit";
          co = "checkout";
          last = "log -1 HEAD";
          st = "status";
          unstage = "reset HEAD --";
        };
        enable = true;
        extraConfig = {
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
      kitty = {
        enable = true;
        extraConfig = builtins.readFile ./home/programs/kitty/kitty.conf;
        font = {
          name = "Hasklug Nerd Font";
        };
        settings = {
          shell = "zsh";
        };
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
            config = builtins.readFile ./home/programs/neovim/nord-vim.vim;
            plugin = nord-vim;
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
      tmux = {
        clock24 = true;
        enable = true;
        historyLimit = 100000;
        escapeTime = 20;
        focusEvents = true;
        keyMode = "vi";
        plugins = with pkgs.tmuxPlugins; [
          nord
          pain-control
          yank
        ];
        sensibleOnTop = true;
        shell = "${pkgs.zsh}/bin/zsh";
        terminal = "tmux-256color";
        tmuxinator.enable = true;
        extraConfig = ''
          set-window-option -g other-pane-height 80
          set -g mouse on
          set -gu default-command
          set -g default-shell "$SHELL"
        '';
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
        initExtra = builtins.readFile ./home/programs/.zshrc;
        shellAliases = {
          mux = "tmuxinator";
        };
      };
    };
}
