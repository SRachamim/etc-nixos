{ ... }:

{
  virtualisation = {
    podman = {
      dockerCompat = true;
      enable = true;
    };
    virtualbox.host.enable = true;
  };
  users.extraGroups.vboxusers.members = [ "user" ];
}
