{ ... }:

{
  virtualisation = {
    podman = {
      dockerCompat = true;
      enable = true;
    };
  };
  users.extraGroups.vboxusers.members = [ "user" ];
}
