{ lib, pkgs, ... }:
{
  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "adobe-reader"
      "bitwig-studio"
      "davinci-resolve"
      "falcon-sensor"
      "google-chrome"
      "spotify"
      "spotify-unwrapped"
    ];
    permittedInsecurePackages = [
      "adobe-reader-9.5.5"
    ];
  };
}
