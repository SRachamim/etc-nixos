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
      brave
      cargo
      element-desktop
      fd
      mpv
      nodejs_latest
      ripgrep
      rustc
      signal-desktop
      unzip
      vim
      wl-clipboard
    ];
  };
}
