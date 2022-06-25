{ ... }:

{
  users.users.user = {
    extraGroups = [
      "adbusers"
      "networkmanager"
      "video"
      "wheel"
    ];
    isNormalUser = true;
  };
}
