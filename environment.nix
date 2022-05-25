{ pkgs, ... }:

{
  environment = {
    etc = {
      machine-id = {
        text = "b08dfa6083e7567a1921a715000001fb";
      };
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    systemPackages = with pkgs; [
      bitwarden
      brave
      element-desktop
      freetube
      nodejs_latest
      ripgrep
      signal-desktop
      xclip
    ];
  };
}
