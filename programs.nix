{ pkgs, ... }:
{
  programs = {
    adb = {
      enable = true;
    };
    light.enable = true;
    wshowkeys = {
      enable = true;
    };
  };
}
