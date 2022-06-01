{ ... }:
{
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
    syncthing = {
      devices = {
        "android" = {
          id = "WLFRIYD-Z2H7ULC-B5DQVK4-ONNA5C3-EOEWDMH-4VD4BIT-26ME36A-W6BZ2QS";
        };
      };
      enable = true;
      overrideDevices = true;
    };
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
      layout = "us,il,de";
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
      xkbOptions = "caps:escape";
    };
  };
}
