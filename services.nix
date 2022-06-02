{ pkgs, ... }:
{
  services = {
    blueman.enable = true;
    fwupd.enable = true;
    greetd = {
      enable = true;
      settings = rec {
        default_session = initial_session;
        initial_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
          user = "greeter";
        };
      };
      vt = 2;
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
  };
}
