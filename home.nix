{ config, pkgs, ... }:
let
    home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];
  home-manager.users.user = {
    home.file = {
      ".background-image" = {
        source = ./home/file/.background-image.png;
        target = ".background-image";
      };
      "tmuxinator-fg.yaml" = {
        source = ./home/file/tmuxinator/fg.yaml;
        target = ".config/tmuxinator/fg.yaml";
      };
      "sway" = {
        source = ./home/file/sway;
        target = ".config/sway";
      };
      "waybar" = {
        source = ./home/file/waybar;
        target = ".config/waybar";
      };
    };
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
        delta = {
          enable = true;
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
          name = "Hasklig";
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
          coc-css
          coc-html
          coc-json
          coc-markdownlint
          coc-sh
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
          sniprun
          vim-commentary
          vim-devicons
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
        terminal = "tmux";
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
        enableAutosuggestions = true;
        enableSyntaxHighlighting = true;
        initExtra = builtins.readFile ./home/programs/.zshrc;
        shellAliases = {
          bd = "fg bd";
          fg = "lxc exec FG -- ";
          jcps = "fg ps -aufx | grep jumpcloud";
          jcpull = ''fg "cd fgrepo && git pull"'';
          jcrestart = "fg systemctl restart jcagent";
          jcstart = "fg systemctl start jcagent";
          jcstatus = "fg systemctl status jcagent";
          jcstop = "fg systemctl stop jcagent";
          lock = "~/.config/sway/lock.sh";
          mux = "tmuxinator";
        };
      };
    };
  };
}
