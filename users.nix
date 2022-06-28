{ ... }:

{
  users.users.user = {
    extraGroups = [
      "adbusers"
      "lxd"
      "networkmanager"
      "video"
      "wheel"
    ];
    isNormalUser = true;
  };
}
