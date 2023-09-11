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
    xserver = {
      desktopManager = {
        plasma5 = {
          enable = true;
        };
      };
      displayManager = {
        defaultSession = "plasmawayland";
        sddm = {
          enable = true;
        };
      };
      enable = true;
    };
  };
}
