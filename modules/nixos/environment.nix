{ pkgs, ... }:
{
  environment = {
    etc = {
      machine-id = {
        text = "b08dfa6083e7567a1921a715000001fb";
      };
    };
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
    systemPackages = with pkgs; [
      amberol
      bitwarden
      cargo
      element-desktop
      fd
      google-chrome
      mpv
      nodejs_latest
      ripgrep
      rustc
      signal-desktop
      spotify
      stremio
      unzip
      vim
      wl-clipboard
    ];
  };
}
