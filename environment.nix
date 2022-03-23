{ pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    bitwarden
    bitwarden-cli
    blender
    chromium
    cool-retro-term
    element-desktop
    freetube
    gimp
    jless
    joplin
    lbry
    lightworks
    mpv
    neofetch
    nodejs_latest
    ranger
    reaper
    ripgrep
    signal-desktop
    speedtest-cli
    spotify
    tahoe-lafs
    tor-browser-bundle-bin
    xclip
    xorg.xmessage
  ];
}
