{ pkgs, ... }:
{
  programs = {
    sway = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        mako
        swayidle
        swaylock
        wl-clipboard
      ];
      wrapperFeatures.gtk = true;
    };
  };
}
