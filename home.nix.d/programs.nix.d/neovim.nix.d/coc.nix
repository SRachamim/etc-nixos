{ pkgs, ... }:

{
  home-manager.users.user.programs.neovim.coc = {
    enable = true;
    settings = {
      "eslint.autoFixOnSave" = true;
      "tsserver.enableJavascript" = false;
    };
  };
}
