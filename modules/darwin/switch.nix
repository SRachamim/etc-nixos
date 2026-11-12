# `switch` applies the main checkout's flake. sudo lets the primary user run
# exactly this command line without a password, so agents can apply their
# changes; any other darwin-rebuild invocation still asks for one.
{ config, lib, pkgs, ... }:
let
  cmd = "/run/current-system/sw/bin/darwin-rebuild switch --flake /Volumes/Development/github.com/srachamim/etc-nixos.git/main#macbook";
  # sudoers reads an unescaped `#` as the start of a comment, which would cut
  # the rule off before `#macbook` so it never matches.
  sudoersCmd = lib.replaceStrings [ "#" ] [ "\\#" ] cmd;
in
{
  security.sudo.extraConfig = ''
    ${config.system.primaryUser} ALL=(root) NOPASSWD: ${sudoersCmd}
  '';

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "switch" "exec sudo ${cmd}")
  ];
}
