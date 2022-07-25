{ lib, pkgs, ... }:
{
  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "google-chrome"
      "spotify"
      "spotify-unwrapped"
    ];
  };
}
