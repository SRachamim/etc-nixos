{ pkgs, ... }:

{
  systemd.services.tahoe = {
    serviceConfig = {
      ExecStart = "${pkgs.tahoe-lafs}/bin/tahoe run ~/.tahoe";
    };
  };
}
