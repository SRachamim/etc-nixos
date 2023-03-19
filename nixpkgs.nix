{ lib, pkgs, ... }:
{
  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "adobe-reader"
      "bitwig-studio"
      "davinci-resolve"
      "discord"
      "falcon-sensor"
      "google-chrome"
      "postman"
      "slack"
      "spotify"
      "spotify-unwrapped"
    ];
    permittedInsecurePackages = [
      "adobe-reader-9.5.5"
    ];
  };
}
