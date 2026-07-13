{ ... }:
{
  system.defaults = {
    dock = {
      autohide = true;
      mru-spaces = false;
      show-recents = false;
    };
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      FXPreferredViewStyle = "clmv";
      ShowPathbar = true;
      ShowStatusBar = true;
    };
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };
  };
}
