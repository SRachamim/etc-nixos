{ ... }:

{
  users.users.user = {
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    isNormalUser = true;
  };
}
