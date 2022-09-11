{ ... }:

{
  virtualisation = {
    lxd = {
      enable = true;
    };
    podman = {
      dockerCompat = true;
      enable = true;
    };
    virtualbox = {
      host = {
        enable = true;
      };
    };
  };
  users.extraGroups.vboxusers.members = [
    "user"
    "user-with-access-to-virtualbox"
  ];
}
