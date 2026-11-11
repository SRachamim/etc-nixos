# `switch` applies the checkout's flake. sudo lets the user run exactly this
# command line without a password, so agents can apply their changes; any
# other nixos-rebuild invocation still asks for one.
{ pkgs, ... }:
let
  cmd = "/run/current-system/sw/bin/nixos-rebuild switch --flake /etc/nixos#SaharRachamim";
in
{
  security.sudo.extraRules = [
    {
      users = [ "user" ];
      commands = [
        {
          command = cmd;
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "switch" "exec sudo ${cmd}")
  ];
}
