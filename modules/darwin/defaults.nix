{ ... }:
{
  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.0;
      expose-animation-duration = 0.1;
      launchanim = false;
      minimize-to-application = true;
      mru-spaces = false;
      show-recents = false;
      tilesize = 36;
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
      NSAutomaticWindowAnimationsEnabled = false;
      NSWindowResizeTime = 0.001;
      _HIHideMenuBar = false;
    };
    CustomUserPreferences = {
      NSGlobalDomain = {
        AppleMenuBarVisibleInFullscreen = false;
      };
    };
    WindowManager = {
      EnableStandardClickToShowDesktop = false;
      EnableTilingByEdgeDrag = false;
      EnableTopTilingByEdgeDrag = false;
      EnableTilingOptionAccelerator = false;
      StandardHideDesktopIcons = true;
    };
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };
  };

  # macOS caches menu-bar prefs in SystemUIServer; on macOS 26 changes to
  # _HIHideMenuBar aren't picked up until it restarts. Refresh it at the end
  # of activation so menu-bar defaults apply on `switch` without a logout.
  system.activationScripts.postActivation.text = ''
    killall SystemUIServer 2>/dev/null || true
  '';
}
