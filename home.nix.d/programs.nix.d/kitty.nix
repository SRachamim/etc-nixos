{ ... }:

{
  home-manager.users.user.programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./kitty.nix.d/theme.conf;
    font = {
      name = "JetBrainsMono Nerd Font Mono Regular";
    };
    settings = {
      shell = "zsh";
    };
  };
}
