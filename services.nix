{ ... }:

{
  # List services that you want to enable:
  services = {
    blueman.enable = true;

    fwupd.enable = true;

    geoclue2.appConfig.redshift.isAllowed = true;

    picom = {
      enable = true;
      fade = true;
      fadeDelta = 4;
      shadow = true;
    };

    # Enable CUPS to print documents.
    printing.enable = true;
  
    redshift = {
      brightness = {
        day = "1";
        night = "1";
      };
      enable = true;
      temperature = {
        day = 5500;
        night = 3700;
      };
    };

    # Enable the X11 windowing system.
    xserver = {
      enable = true;   

      desktopManager = {
        xterm.enable = false;
        xfce = {
          enable = true;
          enableXfwm = false;
          noDesktop = true;
        };
      };

      displayManager.defaultSession = "xfce+xmonad";

      layout = "us,il";

      windowManager = {
        xmonad = {
          enable = true;
          enableContribAndExtras = true;
          extraPackages = haskellPackages : [
            haskellPackages.xmonad
            haskellPackages.xmonad-contrib
            haskellPackages.xmonad-extras
          ];
        };
      };

      # Configure keymap in X11
      xkbOptions = "caps:escape";
    };
  };
}
