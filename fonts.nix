{ pkgs, ... }:
{
  fonts.fonts = with pkgs; [
    hasklig
    nerdfonts
  ];
}
