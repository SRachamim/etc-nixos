{ ... }:

{
  home-manager.users.sahar.xsession.windowManager.xmonad = {
    config = ./xmonad.nix.d/xmonad.hs;
    enable = true;
    enableContribAndExtras = true;
  };
}
