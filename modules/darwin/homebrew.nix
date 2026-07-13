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
    casks = [
      "nikitabobko/tap/aerospace"
      "ghostty"
    ];
  };
}
