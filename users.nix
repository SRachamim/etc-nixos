{ ... }:

{
  users.users.user = {
    extraGroups = [
      "networkmanager"
      "video"
      "wheel"
    ];
    isNormalUser = true;
  };
}
