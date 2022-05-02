{ ... }:

{
  home-manager.users.user.programs.xmobar = {
    enable = true;
    extraConfig = builtins.readFile ./xmobar.nix.d/xmobarrc.hs;
  };
}
