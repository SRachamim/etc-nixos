{ ... }:

{
  home-manager.users.user.programs.rofi = {
    enable = true;
    theme = ./rofi.nix.d/theme.rasi;
  };
}
