{ pkgs, ... }:
{
  services = {
    dbus.enable = true;
    fwupd.enable = true;
    pipewire = {
      alsa.enable = true;
      enable = true;
      pulse.enable = true;
    };
    printing.enable = true;
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
      desktopManager = {
        plasma5 = {
          enable = true;
        };
      };
      displayManager = {
        sddm = {
          enable = true;
        };
      };
      enable = true;
    };
  };
}
