{ ... }:

{
  home-manager.users.user.xsession.windowManager.xmonad = {
    config = ./xmonad.nix.d/xmonad.hs;
    enable = true;
    enableContribAndExtras = true;
  };
}
