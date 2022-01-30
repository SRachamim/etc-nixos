{ ... }:

{
  home-manager.users.sahar.home.file = {
    ".background-image" = {
      source = ./file.nix.d/.background-image.png;
      target = ".background-image";
    };
    "tmuxinator-fg.yaml" = {
      source = ./file.nix.d/tmuxinator/fg.yaml;
      target = ".config/tmuxinator/fg.yaml";
    };
  };
}
