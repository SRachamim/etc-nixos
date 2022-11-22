{ lib, pkgs, ... }:
{
  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "falcon-sensor"
      "google-chrome"
      "spotify"
      "spotify-unwrapped"
    ];
  };
}
