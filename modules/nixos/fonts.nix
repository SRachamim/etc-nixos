{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    hasklig
    nerd-fonts.fira-code
  ];
}
