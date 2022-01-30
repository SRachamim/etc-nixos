{ ... }:

{
  home-manager.users.sahar.programs.rofi = {
    enable = true;
    theme = ./rofi.nix.d/theme.rasi;
  };
}
