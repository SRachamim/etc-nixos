{ ... }:
{
  imports = [ 
    "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/dell/precision/5530"
    ./boot.nix
    ./environment.nix
    ./fonts.nix
    ./hardware-configuration.nix
    ./hardware.nix
    ./home.nix
    ./location.nix
    ./networking.nix
    ./nixpkgs.nix
    ./programs.nix
    ./services.nix
    ./system.nix
    ./time.nix
    ./users.nix
    ./virtualisation.nix
  ];
}
