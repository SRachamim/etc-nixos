{
  description = "Personal NixOS + nix-darwin configuration with home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";

    nixCats.url = "github:BirdeeHub/nixCats-nvim";

  };

  outputs = inputs@{ self, nixpkgs, nixos-hardware, home-manager, nix-darwin, catppuccin, nixCats, ... }:
  let
    overlays = [ (import ./overlays) ];
  in
  {
    nixosConfigurations.SaharRachamim = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.overlays = overlays; }
        nixos-hardware.nixosModules.dell-precision-5530
        ./hosts/nixos/configuration.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.user = {
            imports = [
              catppuccin.homeModules.catppuccin
              ./home/shared.nix
              ./home/nixos.nix
              ./home/programs/neovim
            ];
          };
        }
      ];
    };

    darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.overlays = overlays; }
        ./hosts/darwin/configuration.nix

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users."sahar.rachamim" = {
            imports = [
              catppuccin.homeModules.catppuccin
              ./home/shared.nix
              ./home/darwin.nix
              ./home/programs/neovim
            ];
          };
        }
      ];
    };

    # Standalone home-manager configuration for use before nix-darwin is
    # bootstrapped.  Run: home-manager switch --flake .#sahar.rachamim
    # After installing nix-darwin, switch to: darwin-rebuild switch --flake .#macbook
    homeConfigurations."sahar.rachamim" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      extraSpecialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.overlays = overlays; }
        catppuccin.homeModules.catppuccin
        ./home/shared.nix
        ./home/darwin.nix
        ./home/programs/neovim
      ];
    };
  };
}
