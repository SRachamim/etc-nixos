{ pkgs, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        configurationLimit = 42;
        enable = true;
      };
    };
  };
}
