{ pkgs, ... }:

{
  home-manager.users.sahar.programs.firefox = {
    enable = true;
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      bitwarden
      ublock-origin
    ];
    profiles = {
      kishu = {
	isDefault = true;
      };
    };
  };
}
