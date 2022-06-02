{ pkgs, ... }:
{
  environment = {
    etc = {
      machine-id = {
        text = "b08dfa6083e7567a1921a715000001fb";
      };
    };
    systemPackages = with pkgs; [
      bitwarden
      brave
      brightnessctl
      element-desktop
      freetube
      nodejs_latest
      ripgrep
      signal-desktop
      xclip
    ];
  };
}
