{ pkgs, ... }:

{
  imports = [
    ./windowManager.nix.d/xmonad.nix
  ];
}
