{ pkgs, ... }:

{
  home-manager.users.user.gtk = {
    enable = true;

    theme = {
      name = "Nordic";
      package = pkgs.nordic;
    };
  };
}
