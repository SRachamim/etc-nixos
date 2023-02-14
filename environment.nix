{ pkgs, ... }:
{
  environment = {
    etc = {
      machine-id = {
        text = "b08dfa6083e7567a1921a715000001fb";
      };
    };
    systemPackages = with pkgs; [
      adobe-reader
      bitwarden
      bitwig-studio
      davinci-resolve
      element-desktop
      fd
      fx
      gimp
      google-chrome
      htop
      mpv
      nodejs_latest
      ripgrep
      signal-desktop
      spotify
      unzip
      vim
      vimgolf
      wine
    ];
  };
}
