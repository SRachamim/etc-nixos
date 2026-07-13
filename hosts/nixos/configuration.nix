{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/shared/nix.nix
    ../../modules/nixos/boot.nix
    ../../modules/nixos/environment.nix
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/hardware.nix
    ../../modules/nixos/location.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/nixpkgs.nix
    ../../modules/nixos/programs.nix
    ../../modules/nixos/services.nix
    ../../modules/nixos/system.nix
    ../../modules/nixos/time.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/virtualisation.nix
    ../../modules/nixos/xdg.nix
  ];

  nix.channel.enable = false;
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
}
