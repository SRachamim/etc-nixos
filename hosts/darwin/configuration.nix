{ pkgs, inputs, ... }:
{
  imports = [
    ../../modules/shared/nix.nix
    ../../modules/darwin/defaults.nix
    ../../modules/darwin/homebrew.nix
  ];

  system.primaryUser = "sahar.rachamim";

  users.users."sahar.rachamim" = {
    home = "/Users/sahar.rachamim";
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    fd
    ripgrep
    vim
  ];

  programs.zsh.enable = true;

  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  system.stateVersion = 6;
}
