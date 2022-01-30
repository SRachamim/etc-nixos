{ ... }:

{
  home-manager.users.sahar.programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv = {
      enable = true;
    };
  };
}
