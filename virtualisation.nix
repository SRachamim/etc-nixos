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
  };
  users.extraGroups.vboxusers.members = [ "user" ];
}
