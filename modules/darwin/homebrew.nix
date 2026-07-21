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
      { name = "FelixKratz/formulae"; trusted = true; }
      "nikitabobko/tap"
      "raine/workmux"
    ];
    brews = [
      "media-control"
      { name = "sketchybar"; start_service = true; restart_service = "changed"; }
      "raine/workmux/workmux"
    ];
    casks = [
      "nikitabobko/tap/aerospace"
      "antigravity"
      "cursor"
      "ghostty"
      "google-chrome"
      "google-drive"
      "sf-symbols"
      "signal"
    ];
  };
}
