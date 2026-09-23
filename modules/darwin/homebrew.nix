{ ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    taps = [
      "nikitabobko/tap"
    ];
    brews = [
      "aoe"
      "workmux"
    ];
    casks = [
      "nikitabobko/tap/aerospace"
      "cursor"
      "ghostty"
      "google-chrome"
      "google-drive"
      "sf-symbols"
      "signal"
    ];
  };
}
