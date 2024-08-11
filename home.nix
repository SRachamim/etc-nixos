{ config, pkgs, ... }:
{
    home.stateVersion = "23.05";
    home.file = {
      "tmuxinator-fg.yaml" = {
        source = ./home/file/tmuxinator/fg.yaml;
        target = ".config/tmuxinator/fg.yaml";
      };
    };
    home.packages = with pkgs; [
      fd
      nerdfonts
      ripgrep
      podman
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
          core = {
            editor = "vim";
          };
          init = {
            defaultBranch = "master";
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
        enableAliases = true;
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
          coc-python
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
          set -g mouse on
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
          bd = "fg bd";
          fg = "lxc exec fg -- ";
          jcps = "fg ps -aufx | grep jumpcloud";
          jcpull = ''fg "cd fgrepo && git pull"'';
          jcrestart = "fg systemctl restart jcagent";
          jcstart = "fg systemctl start jcagent";
          jcstatus = "fg systemctl status jcagent";
          jcstop = "fg systemctl stop jcagent";
          mux = "tmuxinator";
        };
      };
    };
}
