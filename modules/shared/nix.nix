{ lib, pkgs, ... }:
{
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    } // lib.optionalAttrs pkgs.stdenv.isLinux {
      dates = "weekly";
    } // lib.optionalAttrs pkgs.stdenv.isDarwin {
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
    };

    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };
}
