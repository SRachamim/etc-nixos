{ config, pkgs, lib, inputs, ... }:
let
  utils = inputs.nixCats.utils;
in
{
  imports = [ inputs.nixCats.homeModule ];

  config.nixCats = {
    enable = true;
    packageNames = [ "nvim" ];
    luaPath = ./.;

    addOverlays = [
      (utils.standardPluginOverlay inputs)
    ];

    categoryDefinitions.replace = { pkgs, settings, categories, extra, name, mkPlugin, ... }: {
      lspsAndRuntimeDeps = {
        general = with pkgs; [
          ripgrep
          fd
          lazygit
          nodejs
          tree-sitter
          lua-language-server
          nil
          bash-language-server
          typescript-language-server
          vscode-langservers-extracted
          pngpaste
        ];
      };

      startupPlugins = {
        general = with pkgs.vimPlugins; [
          lz-n
          catppuccin-nvim
          snacks-nvim
          nvim-web-devicons
          plenary-nvim
          nui-nvim
          dressing-nvim

          # Git (always loaded)
          vim-gitgutter
          vim-highlightedyank
          git-messenger-vim

          # Editing (always loaded)
          vim-closetag
          vim-commentary
          vim-hardtime
          vim-repeat
          vim-surround
          vim-unimpaired
          vim-html-template-literals

          # Org mode
          vim-orgmode
          orgmode

          # LSP completion sources (needed when LSP loads)
          nvim-cmp
          cmp-nvim-lsp
          cmp-buffer
          cmp-path

          # Treesitter (grammars bundled via Nix)
          nvim-treesitter.withAllGrammars

          # AI (always loaded)
          pkgs.agentic-nvim
        ];
      };

      optionalPlugins = {
        lsp = with pkgs.vimPlugins; [
          nvim-lspconfig
        ];

        telescope = with pkgs.vimPlugins; [
          telescope-nvim
          telescope-fzf-native-nvim
        ];

        ui = with pkgs.vimPlugins; [
          lualine-nvim
        ];

        git = with pkgs.vimPlugins; [
          lazygit-nvim
          diffview-nvim
        ];

        ai = with pkgs.vimPlugins; [
          pkgs.claudecode-nvim
          avante-nvim
        ];
      };
    };

    packageDefinitions.replace = {
      nvim = { pkgs, name, ... }: {
        settings = {
          wrapRc = true;
          aliases = [ "vim" "vimdiff" ];
          hosts.python3.enable = false;
          hosts.node.enable = false;
          hosts.ruby.enable = false;
        };
        categories = {
          general = true;
          lsp = true;
          telescope = true;
          ui = true;
          git = true;
          editing = true;
          orgmode = true;
          ai = true;
        };
      };
    };
  };
}
