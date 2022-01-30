{ pkgs, ... }:

{
  imports = [
    ./xsession.nix.d/windowManager.nix
  ];
}
