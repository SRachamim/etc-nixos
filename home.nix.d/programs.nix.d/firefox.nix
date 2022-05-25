{ pkgs, ... }:

{
  home-manager.users.user.programs.firefox = {
    enable = true;
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      ublock-origin
    ];
    profiles = {
      user = {
	      isDefault = true;
      };
    };
  };
}
