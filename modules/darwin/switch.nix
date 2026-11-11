# `switch` applies the main checkout's flake. sudo lets the primary user run
# exactly this command line without a password, so agents can apply their
# changes; any other darwin-rebuild invocation still asks for one.
{ config, pkgs, ... }:
let
  cmd = "/run/current-system/sw/bin/darwin-rebuild switch --flake /Volumes/Development/github.com/srachamim/etc-nixos.git/main#macbook";
in
{
  security.sudo.extraConfig = ''
    ${config.system.primaryUser} ALL=(root) NOPASSWD: ${cmd}
  '';

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "switch" "exec sudo ${cmd}")
  ];
}
