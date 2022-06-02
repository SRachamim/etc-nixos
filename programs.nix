{ pkgs, ... }:
{
  programs = {
    sway = {
      enable = true;
      extraPackages = with pkgs; [
        alacritty
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
