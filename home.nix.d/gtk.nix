{ pkgs, ... }:

{
  home-manager.users.sahar.gtk = {
    enable = true;

    theme = {
      name = "Nordic";
      package = pkgs.nordic;
    };
  };
}
