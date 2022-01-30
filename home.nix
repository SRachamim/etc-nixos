{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";

in
{
  imports = [
    (import "${home-manager}/nixos")
    ./home.nix.d/gtk.nix
   # ./keyboard.nix
   # ./nixpkgs.nix
    ./home.nix.d/file.nix
    ./home.nix.d/programs.nix
   # ./targets.nix
   # ./xdg.nix
    ./home.nix.d/xsession.nix
  ];
}
