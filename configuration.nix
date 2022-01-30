# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ ... }:

{
  imports = [ 
    "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/common/gpu/nvidia.nix"

    "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/dell/precision/5530"

    ./boot.nix

    ./environment.nix

    ./fonts.nix

    ./hardware.nix

    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ./home.nix

    ./location.nix

    ./networking.nix

    ./nixpkgs.nix

    ./programs.nix

    ./services.nix

    ./system.nix

    ./systemd.nix

    ./time.nix

    ./users.nix

    ./virtualisation.nix
  ];
}
