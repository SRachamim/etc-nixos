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
      # Disabled: kept installed & configured, but the service no longer runs
      # (native macOS menu bar is used instead). Re-enable by restoring
      # start_service = true; restart_service = "changed";
      { name = "sketchybar"; start_service = false; }
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
