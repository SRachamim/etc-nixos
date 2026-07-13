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
      "raine/workmux"
    ];
    brews = [
      "raine/workmux/workmux"
    ];
    casks = [
      "nikitabobko/tap/aerospace"
      "ghostty"
    ];
  };
}
