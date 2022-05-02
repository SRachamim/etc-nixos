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
      bitwarden-cli
      blender
      chromium
      cool-retro-term
      dig
      element-desktop
      freetube
      gimp
      jless
      joplin
      lbry
      libreoffice
      mpv
      neofetch
      nodejs_latest
      protonmail-bridge
      ranger
      ripgrep
      signal-desktop
      speedtest-cli
      tahoe-lafs
      tor-browser-bundle-bin
      tor-browser-bundle-bin
      wireshark
      xclip
      xorg.xmessage
    ];
  };
}
