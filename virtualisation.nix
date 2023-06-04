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
}
