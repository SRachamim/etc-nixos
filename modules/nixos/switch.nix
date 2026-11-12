# `switch` applies the checkout's flake. sudo lets the user run exactly this
# command line without a password, so agents can apply their changes; any
# other nixos-rebuild invocation still asks for one.
{ lib, pkgs, ... }:
let
  cmd = "/run/current-system/sw/bin/nixos-rebuild switch --flake /etc/nixos#SaharRachamim";
in
{
  security.sudo.extraRules = [
    {
      users = [ "user" ];
      commands = [
        {
          # sudoers reads an unescaped `#` as the start of a comment, which
          # would cut the rule off before `#SaharRachamim` so it never matches.
          command = lib.replaceStrings [ "#" ] [ "\\#" ] cmd;
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "switch" "exec sudo ${cmd}")
  ];
}
