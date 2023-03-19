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
      adobe-reader
      bitwarden
      bitwig-studio
      brave
      davinci-resolve
      discord
      element-desktop
      fd
      fx
      gimp
      google-chrome
      htop
      libreoffice
      mpv
      nodejs_latest
      pirate-get
      postman
      ripgrep
      signal-desktop
      slack
      spotify
      thunderbird
      transmission-qt
      unzip
      vim
      vimgolf
      wine
      wl-clipboard
    ];
  };
}
